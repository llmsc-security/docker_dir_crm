#!/usr/bin/env python3
import json
import subprocess
import sys
import os
import time
import requests
from datetime import datetime

# Configuration
PORT_MAPPING = {
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

REPO_DIRS = {
    "yuka-friends--Windrecorder": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/yuka-friends--Windrecorder",
    "microsoft--magentic-ui": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/microsoft--magentic-ui",
    "InternLM--HuixiangDou": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/InternLM--HuixiangDou",
    "fynnfluegge--codeqai": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/fynnfluegge--codeqai",
    "snap-stanford--Biomni": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/snap-stanford--Biomni",
    "zwq2018--Data-Copilot": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/zwq2018--Data-Copilot",
    "bhaskatripathi--pdfGPT": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/bhaskatripathi--pdfGPT",
    "finaldie--auto-news": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/finaldie--auto-news",
    "zyddnys--manga-image-translator": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/zyddnys--manga-image-translator",
    "IBM--zshot": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs_50/IBM--zshot"
}

INVOKE_SCRIPTS = {
    "yuka-friends--Windrecorder": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/yuka-friends--Windrecorder/invoke_yuka-friends--Windrecorder.sh",
    "microsoft--magentic-ui": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/microsoft--magentic-ui/invoke_microsoft--magentic-ui.sh",
    "InternLM--HuixiangDou": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/InternLM--HuixiangDou/invoke_InternLM--HuixiangDou.sh",
    "fynnfluegge--codeqai": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/fynnfluegge--codeqai/invoke_fynnfluegge--codeqai.sh",
    "snap-stanford--Biomni": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/snap-stanford--Biomni/invoke_snap-stanford--Biomni.sh",
    "zwq2018--Data-Copilot": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/zwq2018--Data-Copilot/invoke_zwq2018--Data-Copilot.sh",
    "bhaskatripathi--pdfGPT": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/bhaskatripathi--pdfGPT/invoke_bhaskatripathi--pdfGPT.sh",
    "finaldie--auto-news": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/invoke_finaldie--auto-news.sh",
    "zyddnys--manga-image-translator": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/zyddnys--manga-image-translator/invoke_zyddnys--manga-image-translator.sh",
    "IBM--zshot": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/IBM--zshot/invoke_IBM--zshot.sh"
}

# Tutorial scripts
TUTORIAL_SCRIPTS = {
    "yuka-friends--Windrecorder": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/yuka-friends--Windrecorder/tutorial_yuka-friends--Windrecorder_poc.sh",
    "microsoft--magentic-ui": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/microsoft--magentic-ui/tutorial_microsoft--magentic-ui_poc.sh",
    "InternLM--HuixiangDou": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/InternLM--HuixiangDou/tutorial_InternLM--HuixiangDou_poc.sh",
    "fynnfluegge--codeqai": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/fynnfluegge--codeqai/tutorial_fynnfluegge--codeqai_poc.sh",
    "snap-stanford--Biomni": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/snap-stanford--Biomni/tutorial_snap-stanford--Biomni_poc.sh",
    "zwq2018--Data-Copilot": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/zwq2018--Data-Copilot/tutorial_zwq2018--Data-Copilot_poc.sh",
    "bhaskatripathi--pdfGPT": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/bhaskatripathi--pdfGPT/tutorial_bhaskatripathi--pdfGPT_poc.sh",
    "finaldie--auto-news": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/finaldie--auto-news/tutorial_finaldie--auto-news_poc.sh",
    "zyddnys--manga-image-translator": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/zyddnys--manga-image-translator/tutorial_zyddnys--manga-image-translator_poc.sh",
    "IBM--zshot": "/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/IBM--zshot/tutorial_IBM--zshot_poc.sh"
}

ENV_VARS = {
    "OPENAI_API_KEY": "11",
    "OPENAI_API_BASE_URL": "http://157.10.162.82:443/v1/",
    "GPT_MODEL": "gpt-5.1"
}

RESULTS = []

def run_cmd(cmd, timeout=30):
    """Run shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Command timed out"
    except Exception as e:
        return -1, "", str(e)

def get_container_status(repo_name):
    """Check container status"""
    # Convert repo name to container name format
    container_name = repo_name.replace("--", "-").replace("_", "-") + "_container"
    if "microsoft-magentic-ui" in container_name:
        container_name = "microsoft-magentic-ui_container"
    if "finaldie-auto-news" in container_name:
        container_name = "finaldie-auto-news_container"
    if "bhaskatripathi-pdfgpt" in container_name:
        container_name = "bhaskatripathi-pdfgpt_container"
    if "snap-stanford-biomni" in container_name:
        container_name = "snap-stanford-biomni_container"
    if "zwq2018--Data-Copilot" in container_name:
        container_name = "zwq2018--Data-Copilot"
    if "IBM--zshot" in container_name:
        container_name = "IBM--zshot_container"
    
    returncode, stdout, stderr = run_cmd(f"docker ps -a --filter name={container_name} --format '{{{{.Status}}}}'")
    if returncode == 0:
        status = stdout.strip()
        return status, container_name
    return "not_found", container_name

def check_http_endpoint(port):
    """Test HTTP endpoint"""
    url = f"http://157.10.162.82:{port}"
    try:
        response = requests.get(url, timeout=10, allow_redirects=True)
        return {
            "status_code": response.status_code,
            "url": response.url,
            "headers": dict(response.headers),
            "success": True
        }
    except requests.exceptions.ConnectionError:
        return {"success": False, "error": "Connection refused"}
    except requests.exceptions.Timeout:
        return {"success": False, "error": "Connection timed out"}
    except Exception as e:
        return {"success": False, "error": str(e)}

def get_container_logs(repo_name, tail=50):
    """Get container logs"""
    container_name = repo_name.replace("--", "-").replace("_", "-") + "_container"
    if "microsoft-magentic-ui" in container_name:
        container_name = "microsoft-magentic-ui_container"
    if "finaldie-auto-news" in container_name:
        container_name = "finaldie-auto-news_container"
    if "bhaskatripathi-pdfgpt" in container_name:
        container_name = "bhaskatripathi-pdfgpt_container"
    if "snap-stanford-biomni" in container_name:
        container_name = "snap-stanford-biomni_container"
    if "zwq2018--Data-Copilot" in container_name:
        container_name = "zwq2018--Data-Copilot"
    if "IBM--zshot" in container_name:
        container_name = "IBM--zshot_container"
    
    returncode, stdout, stderr = run_cmd(f"docker logs {container_name} --tail {tail}")
    return stdout + stderr

def check_entry_point(repo_name):
    """Check if entry_point.sh exists"""
    repo_dir = REPO_DIRS.get(repo_name, "")
    entry_point = os.path.join(repo_dir, "entry_point.sh")
    return os.path.exists(entry_point)

def check_dockerfile(repo_name):
    """Check if Dockerfile exists"""
    repo_dir = REPO_DIRS.get(repo_name, "")
    dockerfile = os.path.join(repo_dir, "Dockerfile")
    return os.path.exists(dockerfile)

def run_tutorial(repo_name):
    """Run tutorial script if exists"""
    tutorial_script = TUTORIAL_SCRIPTS.get(repo_name, "")
    if not tutorial_script or not os.path.exists(tutorial_script):
        return {"skipped": True, "reason": "No tutorial script found"}
    
    # Set environment variables
    env_cmd = " ".join([f'{k}="{v}"' for k, v in ENV_VARS.items()])
    full_cmd = f"cd {REPO_DIRS[repo_name]} && {env_cmd} bash {tutorial_script}"
    
    start_time = time.time()
    returncode, stdout, stderr = run_cmd(full_cmd, timeout=60)
    elapsed = time.time() - start_time
    
    return {
        "run": True,
        "returncode": returncode,
        "stdout": stdout[:2000] if stdout else "",
        "stderr": stderr[:2000] if stderr else "",
        "elapsed_seconds": round(elapsed, 2)
    }

def run_unit_tests(repo_name):
    """Check if unit tests exist and run them"""
    repo_dir = REPO_DIRS.get(repo_name, "")
    
    # Check for test files
    test_patterns = ["test_", "_test.py", "tests/", "test.py"]
    test_found = False
    tests_run = 0
    tests_passed = 0
    tests_failed = 0
    
    for root, dirs, files in os.walk(repo_dir):
        for f in files:
            if any(pattern in f for pattern in test_patterns) and f.endswith('.py'):
                test_found = True
                tests_run += 1
                test_path = os.path.join(root, f)
                # Try to run pytest or python -m pytest
                returncode, stdout, stderr = run_cmd(f"cd {repo_dir} && python -m pytest {test_path} -v 2>&1 | head -50", timeout=30)
                if returncode == 0:
                    tests_passed += 1
                else:
                    tests_failed += 1
    
    return {
        "found": test_found,
        "tests_run": tests_run,
        "tests_passed": tests_passed,
        "tests_failed": tests_failed,
        "run": test_found
    }

def verify_repo(repo_name):
    """Verify a single repo"""
    port = PORT_MAPPING[repo_name]
    
    result = {
        "repo": repo_name,
        "port": port,
        "timestamp": datetime.now().isoformat()
    }
    
    print(f"Verifying {repo_name}...")
    
    # 1. Check container status
    status, container_name = get_container_status(repo_name)
    result["container_status"] = status
    result["container_name"] = container_name
    result["container_running"] = "Up" in status and "healthy" in status or "Up" in status
    
    # 2. Test HTTP endpoint
    http_result = check_http_endpoint(port)
    result["http"] = http_result
    
    # 3. Check logs for errors (only if container is running)
    if result["container_running"]:
        logs = get_container_logs(repo_name)
        result["logs_sample"] = logs[:500] if logs else ""
        # Look for error patterns
        error_patterns = ["error", "Error", "ERROR", "failed", "Failed", "exception", "Exception"]
        result["errors_found"] = [line for line in logs.split('\n') if any(p in line for p in error_patterns)][:10]
    else:
        result["logs_sample"] = ""
        result["errors_found"] = []
    
    # 4. Check entry_point.sh and Dockerfile
    result["entry_point_exists"] = check_entry_point(repo_name)
    result["dockerfile_exists"] = check_dockerfile(repo_name)
    
    # 5. Run tutorial
    result["tutorial"] = run_tutorial(repo_name)
    
    # 6. Run unit tests
    result["unit_tests"] = run_unit_tests(repo_name)
    
    return result

def main():
    global RESULTS
    
    print("Starting batch verification...")
    print(f"Repos to verify: {len(PORT_MAPPING)}")
    print("-" * 60)
    
    for repo_name in PORT_MAPPING.keys():
        try:
            result = verify_repo(repo_name)
            RESULTS.append(result)
            
            # Print summary for this repo
            status = "PASS" if result["container_running"] and result["http"].get("success") else "FAIL"
            print(f"[{status}] {repo_name}")
            print(f"  Container: {result['container_status']}")
            print(f"  HTTP: {result['http']}")
            print()
        except Exception as e:
            print(f"ERROR verifying {repo_name}: {e}")
            RESULTS.append({
                "repo": repo_name,
                "error": str(e)
            })
    
    # Generate report
    print("\n" + "=" * 60)
    print("VERIFICATION REPORT")
    print("=" * 60)
    
    # Write JSON report
    with open("/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/batch_verification_report_10.json", "w") as f:
        json.dump(RESULTS, f, indent=2, default=str)
    
    # Print summary table
    print("\nSUMMARY:")
    print("-" * 80)
    print(f"{'Repo':<40} {'Status':<10} {'HTTP':<10} {'Container':<20}")
    print("-" * 80)
    
    for r in RESULTS:
        repo = r.get("repo", "UNKNOWN")
        container_running = r.get("container_running", False)
        http_success = r.get("http", {}).get("success", False)
        
        if container_running and http_success:
            status = "OK"
        elif container_running:
            status = "PARTIAL"
        else:
            status = "FAIL"
        
        print(f"{repo:<40} {status:<10} {'OK' if http_success else 'FAIL':<10} {r.get('container_status', 'N/A'):<20}")
    
    # Detailed findings
    print("\n\nDETAILED FINDINGS:")
    print("=" * 80)
    
    for r in RESULTS:
        print(f"\n{r.get('repo', 'UNKNOWN')}:")
        print(f"  Port: {r.get('port')}")
        print(f"  Container Status: {r.get('container_status')}")
        print(f"  Container Running: {r.get('container_running')}")
        
        http = r.get('http', {})
        print(f"  HTTP Success: {http.get('success', False)}")
        if http.get('success'):
            print(f"    Status Code: {http.get('status_code')}")
        else:
            print(f"    Error: {http.get('error', 'N/A')}")
        
        print(f"  Entry Point Exists: {r.get('entry_point_exists')}")
        print(f"  Dockerfile Exists: {r.get('dockerfile_exists')}")
        
        errors = r.get('errors_found', [])
        if errors:
            print(f"  Errors in Logs ({len(errors)}):")
            for e in errors[:5]:
                print(f"    - {e}")
        
        tutorial = r.get('tutorial', {})
        if tutorial.get('run'):
            print(f"  Tutorial: Exit code {tutorial.get('returncode')}, Time: {tutorial.get('elapsed_seconds')}s")
        
        tests = r.get('unit_tests', {})
        if tests.get('run'):
            print(f"  Unit Tests: {tests.get('tests_passed')}/{tests.get('tests_run')} passed")
    
    print("\n" + "=" * 80)
    print("Report saved to: /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/batch_verification_report_10.json")

if __name__ == "__main__":
    main()
