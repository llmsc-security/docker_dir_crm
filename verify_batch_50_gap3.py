#!/usr/bin/env python3
"""
Batch workflow verification script for all 10 repos from port_mapping_50_gap10_3.json
"""

import subprocess
import json
import os
import sys
import time
import re
from datetime import datetime

# Environment variables for API calls
OPENAI_API_KEY = "11"
OPENAI_API_BASE_URL = "http://157.10.162.82:443/v1/"
GPT_MODEL = "gpt-5.1"

# Repos to verify from port_mapping_50_gap10_3.json
REPOS_TO_VERIFY = {
    "yuka-friends--Windrecorder": 11480,
    "microsoft--magentic-ui": 11240,
    "InternLM--HuixiangDou": 11390,
    "fynnfluegge--codeqai": 11060,
    "snap-stanford--Biomni": 11260,
    "zwq2018--Data-Copilot": 11440,
    "bhaskatripathi--pdfGPT": 11340,
    "finaldie--auto-news": 11190,
    "zyddnys--manga-image-translator": 11080,
    "IBM--zshot": 11200
}

# Base directories
BASE_DIR = "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin"
REPO_DIRS = "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50"
INVOKE_SCRIPTS = "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50"

# Results storage
verification_results = {}

def run_command(cmd, timeout=30, description=""):
    """Run a shell command and return output."""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", f"Command timed out after {timeout}s: {description}"
    except Exception as e:
        return -1, "", f"Exception: {str(e)}"

def check_container_status(container_name):
    """Check if container is running."""
    # Normalize container name for comparison
    normalized_name = container_name.replace(" ", "-").lower()
    
    # Try different naming conventions
    possible_names = [
        container_name.replace("--", "-").replace(" ", "-").lower() + "_container",
        container_name.replace("--", "-").replace(" ", "-").lower(),
        container_name.lower(),
        container_name.replace("--", "_").lower(),
        container_name.replace("--", "-").replace(" ", "-").lower(),
    ]
    
    for name in possible_names:
        rc, stdout, stderr = run_command(f"docker ps -a --format '{{{{.Names}}}}' | grep -i '{name}'", description=f"Check container {name}")
        if rc == 0 and stdout.strip():
            return True, stdout.strip()
    
    # Direct check
    rc, stdout, stderr = run_command(f"docker ps -a --format '{{{{.Names}}}}' | grep -i '{container_name}'", description=f"Check container {container_name}")
    if rc == 0 and stdout.strip():
        return True, stdout.strip()
    
    return False, "not_found"

def test_http_endpoint(port, timeout=10):
    """Test HTTP endpoint with curl."""
    url = f"http://localhost:{port}"
    
    # Try different endpoints
    endpoints = [url, f"{url}/", f"{url}/health", f"{url}/api/health", f"{url}/v1/health"]
    
    for endpoint in endpoints:
        rc, stdout, stderr = run_command(
            f'curl -s -o /dev/null -w "%{{http_code}}" --connect-timeout {timeout} --max-time {timeout} "{endpoint}"',
            timeout=timeout + 5,
            description=f"Test HTTP endpoint {endpoint}"
        )
        if rc == 0:
            return int(stdout.strip()) if stdout.strip().isdigit() else 0, endpoint
    
    # Try with full response
    rc, stdout, stderr = run_command(
        f'curl -s -v --connect-timeout {timeout} --max-time {timeout} "{url}" 2>&1 | head -20',
        timeout=timeout + 5,
        description=f"Test HTTP with verbose {url}"
    )
    
    # Extract status code from verbose output
    status_code = 0
    if "HTTP" in stdout:
        match = re.search(r'HTTP/[\d.]+ (\d+)', stdout)
        if match:
            status_code = int(match.group(1))
    
    return status_code, url

def check_container_logs(container_name, lines=100):
    """Check container logs for errors."""
    rc, stdout, stderr = run_command(f"docker logs {container_name} --tail {lines} 2>&1", description=f"Check logs for {container_name}")
    if rc != 0:
        return f"Could not retrieve logs: {stderr}"
    
    # Look for error patterns
    error_patterns = ["error", "failed", "exception", "crash", "fatal", "panic"]
    error_lines = []
    
    for line in stdout.split('\n'):
        if any(pattern in line.lower() for pattern in error_patterns):
            error_lines.append(line)
    
    if error_lines:
        return f"Errors found in logs:\n" + "\n".join(error_lines[:10])
    
    return "No errors found in logs"

def verify_entry_point_and_dockerfile(repo_dir):
    """Verify entry_point.sh and Dockerfile exist."""
    results = {
        "entry_point_exists": False,
        "dockerfile_exists": False,
        "entry_point_path": "",
        "dockerfile_path": ""
    }
    
    # Check for entry_point.sh
    entry_point_paths = [
        os.path.join(repo_dir, "entry_point.sh"),
        os.path.join(repo_dir, "start.sh"),
        os.path.join(repo_dir, "run.sh"),
        os.path.join(repo_dir, "docker_start.sh"),
    ]
    
    for path in entry_point_paths:
        if os.path.exists(path):
            results["entry_point_exists"] = True
            results["entry_point_path"] = path
            break
    
    # Check for Dockerfile
    dockerfile_paths = [
        os.path.join(repo_dir, "Dockerfile"),
        os.path.join(repo_dir, "Dockerfile.dev"),
        os.path.join(repo_dir, "docker", "Dockerfile"),
    ]
    
    for path in dockerfile_paths:
        if os.path.exists(path):
            results["dockerfile_exists"] = True
            results["dockerfile_path"] = path
            break
    
    return results

def run_tutorial_script(repo_name):
    """Run tutorial script if it exists."""
    script_paths = [
        os.path.join(INVOKE_SCRIPTS, repo_name.replace("--", "--"), f"tutorial_{repo_name.replace('--', '_')}_poc.sh"),
        os.path.join(INVOKE_SCRIPTS, repo_name.replace("--", "_"), f"tutorial_{repo_name.replace('--', '_')}_poc.sh"),
        os.path.join(INVOKE_SCRIPTS, repo_name, f"tutorial_{repo_name.replace('--', '_')}_poc.sh"),
        os.path.join(INVOKE_SCRIPTS, repo_name.replace("--", "_"), f"tutorial_{repo_name.replace('--', '_')}_poc.sh"),
    ]
    
    for script_path in script_paths:
        if os.path.exists(script_path):
            # Try to find the correct invocation script
            rc, stdout, stderr = run_command(f"bash {script_path}", timeout=60, description=f"Run tutorial {script_path}")
            return {
                "script_found": True,
                "script_path": script_path,
                "return_code": rc,
                "stdout": stdout[:500] if stdout else "",
                "stderr": stderr[:500] if stderr else ""
            }
    
    # Try alternative naming
    for script_path in script_paths:
        if os.path.exists(script_path.replace("_poc.sh", ".sh")):
            full_path = script_path.replace("_poc.sh", ".sh")
            rc, stdout, stderr = run_command(f"bash {full_path}", timeout=60, description=f"Run tutorial {full_path}")
            return {
                "script_found": True,
                "script_path": full_path,
                "return_code": rc,
                "stdout": stdout[:500] if stdout else "",
                "stderr": stderr[:500] if stderr else ""
            }
    
    return {
        "script_found": False,
        "script_path": "",
        "return_code": -1,
        "stdout": "No tutorial script found",
        "stderr": ""
    }

def run_unit_tests(repo_dir):
    """Run unit tests if they exist."""
    test_files = [
        os.path.join(repo_dir, "tests", "test_*.py"),
        os.path.join(repo_dir, "test_*.py"),
        os.path.join(repo_dir, "*_test.py"),
        os.path.join(repo_dir, "pytest.ini"),
        os.path.join(repo_dir, "setup.py"),
    ]
    
    for pattern in test_files:
        import glob
        matches = glob.glob(pattern)
        if matches:
            # Try running pytest
            test_file = matches[0]
            rc, stdout, stderr = run_command(f"cd {repo_dir} && python3 -m pytest {test_file} -v --tb=short 2>&1 | head -50", timeout=120, description=f"Run unit tests for {repo_dir}")
            return {
                "tests_found": True,
                "test_file": test_file,
                "return_code": rc,
                "stdout": stdout,
                "stderr": stderr
            }
    
    return {
        "tests_found": False,
        "test_file": "",
        "return_code": -1,
        "stdout": "No unit tests found",
        "stderr": ""
    }

def verify_repo(repo_name, port):
    """Run comprehensive verification for a repo."""
    print(f"\n{'='*60}")
    print(f"Verifying: {repo_name} (Port: {port})")
    print(f"{'='*60}")
    
    result = {
        "repo_name": repo_name,
        "port": port,
        "timestamp": datetime.now().isoformat(),
        "container": {},
        "http": {},
        "logs": "",
        "files": {},
        "tutorial": {},
        "unit_tests": {}
    }
    
    # 1. Check container status
    print("1. Checking container status...")
    container_found, container_name = check_container_status(repo_name)
    result["container"]["found"] = container_found
    result["container"]["name"] = container_name
    
    if container_found:
        rc, stdout, stderr = run_command(f"docker ps -a --filter name={container_name} --format '{{{{.Status}}}}'")
        result["container"]["status"] = stdout.strip() if rc == 0 else "unknown"
        
        rc, stdout, stderr = run_command(f"docker ps -a --filter name={container_name} --format '{{{{.Names}}}}'")
        result["container"]["id"] = stdout.strip().split('\n')[0] if rc == 0 else "unknown"
    else:
        result["container"]["status"] = "not_found"
        result["container"]["id"] = "N/A"
    
    # 2. Test HTTP endpoint
    print("2. Testing HTTP endpoint...")
    status_code, endpoint = test_http_endpoint(port)
    result["http"]["endpoint"] = endpoint
    result["http"]["status_code"] = status_code
    result["http"]["response"] = "success" if status_code == 200 else f"failed ({status_code})"
    
    # 3. Check container logs
    print("3. Checking container logs...")
    if container_found:
        result["logs"] = check_container_logs(container_name)
    else:
        result["logs"] = "Container not found"
    
    # 4. Verify entry_point.sh and Dockerfile exist
    print("4. Verifying entry_point.sh and Dockerfile...")
    repo_dir = os.path.join(REPO_DIRS, repo_name)
    files_info = verify_entry_point_and_dockerfile(repo_dir)
    result["files"] = files_info
    
    # 5. Run tutorial script if it exists
    print("5. Running tutorial script if available...")
    tutorial_result = run_tutorial_script(repo_name)
    result["tutorial"] = tutorial_result
    
    # 6. Run unit tests if they exist
    print("6. Running unit tests if available...")
    unit_test_result = run_unit_tests(repo_dir)
    result["unit_tests"] = unit_test_result
    
    return result

def generate_report(all_results):
    """Generate comprehensive verification report."""
    print("\n" + "="*80)
    print("BATCH WORKFLOW VERIFICATION REPORT")
    print(f"Generated: {datetime.now().isoformat()}")
    print("="*80)
    
    summary = {
        "total": len(all_results),
        "container_running": 0,
        "container_exited": 0,
        "http_success": 0,
        "http_failed": 0,
        "files_complete": 0,
        "tutorial_ran": 0,
        "tests_found": 0,
        "errors_found": 0
    }
    
    for result in all_results:
        repo_name = result["repo_name"]
        
        print(f"\n{'='*80}")
        print(f"REPO: {repo_name}")
        print(f"{'='*80}")
        
        print("\n[CONTAINER STATUS]")
        print(f"  Container Name: {result['container'].get('name', 'N/A')}")
        print(f"  Status: {result['container'].get('status', 'N/A')}")
        print(f"  ID: {result['container'].get('id', 'N/A')}")
        
        if "exited" in result['container'].get('status', '').lower():
            summary["container_exited"] += 1
            summary["errors_found"] += 1
        elif "up" in result['container'].get('status', '').lower() or result['container'].get('found', False):
            summary["container_running"] += 1
        
        print("\n[HTTP ENDPOINT TEST]")
        print(f"  Endpoint: {result['http'].get('endpoint', 'N/A')}")
        print(f"  Status Code: {result['http'].get('status_code', 'N/A')}")
        print(f"  Response: {result['http'].get('response', 'N/A')}")
        
        if result['http'].get('status_code') == 200:
            summary["http_success"] += 1
        else:
            summary["http_failed"] += 1
        
        print("\n[LOGS ANALYSIS]")
        logs = result.get('logs', '')
        if logs:
            if "errors found" in logs.lower() or "error" in logs.lower():
                print("  RED: Errors detected in logs!")
                summary["errors_found"] += 1
            print(f"  {logs[:500]}...")
        else:
            print("  No logs available")
        
        print("\n[FILE VERIFICATION]")
        files = result.get('files', {})
        print(f"  entry_point.sh: {'EXISTS' if files.get('entry_point_exists') else 'MISSING'} ({files.get('entry_point_path', 'N/A')})")
        print(f"  Dockerfile: {'EXISTS' if files.get('dockerfile_exists') else 'MISSING'} ({files.get('dockerfile_path', 'N/A')})")
        
        if files.get('entry_point_exists') and files.get('dockerfile_exists'):
            summary["files_complete"] += 1
        
        print("\n[TUTORIAL SCRIPT]")
        tutorial = result.get('tutorial', {})
        print(f"  Found: {'YES' if tutorial.get('script_found') else 'NO'}")
        print(f"  Path: {tutorial.get('script_path', 'N/A')}")
        print(f"  Return Code: {tutorial.get('return_code', 'N/A')}")
        if tutorial.get('stdout'):
            print(f"  Output (first 200 chars): {tutorial['stdout'][:200]}...")
        
        if tutorial.get('script_found'):
            summary["tutorial_ran"] += 1
        
        print("\n[UNIT TESTS]")
        tests = result.get('unit_tests', {})
        print(f"  Tests Found: {'YES' if tests.get('tests_found') else 'NO'}")
        print(f"  Test File: {tests.get('test_file', 'N/A')}")
        print(f"  Return Code: {tests.get('return_code', 'N/A')}")
        if tests.get('stdout'):
            print(f"  Output (first 200 chars): {tests['stdout'][:200]}...")
        
        if tests.get('tests_found'):
            summary["tests_found"] += 1
        
        # Print any errors
        if summary["errors_found"] > 0 or result['http'].get('status_code') != 200:
            print("\n[ISSUES FOUND]")
            if result['container'].get('status') and "exited" in result['container'].get('status', '').lower():
                print("  - Container exited with error")
            if result['http'].get('status_code') != 200:
                print(f"  - HTTP endpoint returned status {result['http'].get('status_code')}")
            if "errors found" in logs.lower():
                print("  - Errors in container logs")
            if not files.get('entry_point_exists'):
                print("  - Missing entry_point.sh")
            if not files.get('dockerfile_exists'):
                print("  - Missing Dockerfile")
    
    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    print(f"Total Repos Verified: {summary['total']}")
    print(f"Containers Running: {summary['container_running']}")
    print(f"Containers Exited: {summary['container_exited']}")
    print(f"HTTP Endpoints Working (200): {summary['http_success']}")
    print(f"HTTP Endpoints Failed: {summary['http_failed']}")
    print(f"Files Complete (entry_point + Dockerfile): {summary['files_complete']}")
    print(f"Tutorials Found: {summary['tutorial_ran']}")
    print(f"Unit Tests Found: {summary['tests_found']}")
    print(f"Errors/Issues Found: {summary['errors_found']}")
    print("="*80)
    
    return summary

def main():
    """Main verification function."""
    print("Starting batch workflow verification...")
    print(f"Environment: {OPENAI_API_BASE_URL}")
    print(f"Model: {GPT_MODEL}")
    
    all_results = []
    
    for repo_name, port in REPOS_TO_VERIFY.items():
        try:
            result = verify_repo(repo_name, port)
            all_results.append(result)
            
            # Small delay between repos
            time.sleep(1)
        except Exception as e:
            error_result = {
                "repo_name": repo_name,
                "port": port,
                "timestamp": datetime.now().isoformat(),
                "error": str(e)
            }
            all_results.append(error_result)
            print(f"Error verifying {repo_name}: {str(e)}")
    
    # Generate report
    summary = generate_report(all_results)
    
    # Save detailed JSON report
    report_path = os.path.join(BASE_DIR, "verification_report_50_gap3.json")
    with open(report_path, 'w') as f:
        json.dump(all_results, f, indent=2)
    print(f"\nDetailed JSON report saved to: {report_path}")
    
    # Save text summary
    summary_path = os.path.join(BASE_DIR, "verification_summary_50_gap3.txt")
    with open(summary_path, 'w') as f:
        f.write("BATCH WORKFLOW VERIFICATION SUMMARY\n")
        f.write(f"Generated: {datetime.now().isoformat()}\n")
        f.write(f"Environment: {OPENAI_API_BASE_URL}\n")
        f.write(f"Model: {GPT_MODEL}\n\n")
        f.write(f"Total Repos Verified: {summary['total']}\n")
        f.write(f"Containers Running: {summary['container_running']}\n")
        f.write(f"Containers Exited: {summary['container_exited']}\n")
        f.write(f"HTTP Endpoints Working (200): {summary['http_success']}\n")
        f.write(f"HTTP Endpoints Failed: {summary['http_failed']}\n")
        f.write(f"Files Complete: {summary['files_complete']}\n")
        f.write(f"Tutorials Found: {summary['tutorial_ran']}\n")
        f.write(f"Unit Tests Found: {summary['tests_found']}\n")
        f.write(f"Errors/Issues Found: {summary['errors_found']}\n")
    print(f"Summary saved to: {summary_path}")
    
    return all_results

if __name__ == "__main__":
    main()
