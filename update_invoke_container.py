import os
import re
import subprocess

SCRIPTS_DIR = "./invoke_scripts"

# Define the new lines as a clean string block
NEW_FLAGS = (
    '    --gpus "device=0" \\\n'
    '    -v /home/docker_comm_user/.cache:/root/.cache:rw \\\n'
    '    -v /home/docker_comm_user/.config:/root/.config:rw \\\n'
    '    -v /home/docker_comm_user/.uv:/root/.uv:rw \\'
)

def process_files():
    if not os.path.exists(SCRIPTS_DIR):
        print(f"Error: {SCRIPTS_DIR} not found.")
        return

    new_files = []
    
    for filename in os.listdir(SCRIPTS_DIR):
        if filename.endswith(".sh") and not filename.endswith("_new.sh"):
            origin_path = os.path.join(SCRIPTS_DIR, filename)
            new_path = os.path.join(SCRIPTS_DIR, filename.replace(".sh", "_new.sh"))
            
            with open(origin_path, 'r') as f:
                content = f.read()

            # Regex Explanation:
            # Group 1: 'docker run -d' followed by any flags up to the last backslash and newline
            # Group 2: The $IMAGE_NAME variable at the end
            run_pattern = r"(docker run -d\s+\\.*-p\s+\$HOST_PORT:\$INTERNAL_PORT\s+\\\n)(?:\s+)?(\$IMAGE_NAME)"
            
            if "docker run" in content and "--gpus" not in content:
                # We build the replacement string manually to avoid \g<2> errors
                # We take Group 1, add our NEW_FLAGS, then add Group 2
                match = re.search(run_pattern, content, flags=re.DOTALL)
                if match:
                    new_content = content.replace(
                        match.group(0), 
                        f"{match.group(1)}{NEW_FLAGS}\n    {match.group(2)}"
                    )
                    
                    with open(new_path, 'w') as f:
                        f.write(new_content)
                    new_files.append((origin_path, new_path))

    if not new_files:
        print("No files matched the pattern or they are already updated.")
        return

    # 2. Show the diffs
    print("\n" + "="*50)
    print("REVIEWING CHANGES")
    print("="*50)
    for origin, new in new_files:
        subprocess.run(["git", "diff", "--no-index", "--color", origin, new])

    # 3. Confirmation
    print("\n" + "="*50)
    confirm = input("Apply changes to original files? (y/n): ").lower()

    if confirm == 'y':
        for origin, new in new_files:
            os.replace(new, origin)
            os.chmod(origin, 0o755)
        print("Updated successfully.")
    else:
        print("Changes discarded.")

if __name__ == "__main__":
    process_files()

