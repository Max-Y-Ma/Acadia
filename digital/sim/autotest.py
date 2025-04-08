import subprocess
import os
import sys

def run_command(command):
    """Run a shell command and return its output and error output."""
    print(f"Running command: {command}")  # Print the command before execution
    try:
        result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        return result.stdout, result.stderr
    except Exception as e:
        print(f"Error while executing: {command}\n{e}")
        return "", str(e)

def check_sim_successful(output):
    """Check if 'Sim Successful' is in the last few lines of output."""
    last_lines = output.strip().splitlines()[-10:]  # Adjust if necessary
    return any("Sim Successful" in line for line in last_lines)

def process_testcases(file_path, run_custom):
    """Read testcases.txt, extract paths, and run commands for each testcase."""
    passed_both = []
    failed_spike = []
    failed_sim = []

    try:
        with open(file_path, 'r') as f:
            testcases = f.readlines()

        for testcase in testcases:
            # Clean up the path (remove any surrounding whitespace)
            testcase = testcase.strip()

            if not testcase:
                continue

            # Check for "nospike" and remove it from the testcase
            if testcase.endswith(" nospike"):
                nospike = True
                testcase = testcase[:-len(" nospike")].strip()  # Remove the "nospike"
            else:
                nospike = False

            # Extract filename without directory or extension
            filename = os.path.splitext(os.path.basename(testcase))[0]

            print(f"\nProcessing: {testcase} (Filename: {filename})")

            # Step 1: make compile PROG=<path>
            compile_command = f"make compile PROG={testcase}"
            stdout, stderr = run_command(compile_command)
            print(f"Compilation output for {testcase}:\n{stdout}\n")

            if not nospike:
                # Step 2: make spike ELF=bin/{filename}.elf
                spike_command = f"make spike ELF=bin/{filename}.elf"
                stdout, stderr = run_command(spike_command)
                print(f"Spike output for {filename}:\n{stdout}\n")

            # Step 3: make vc DIR=soc
            vc_command = "make vc DIR=soc"
            stdout, stderr = run_command(vc_command)

            # Check only the last few lines for "Sim Successful"
            if check_sim_successful(stdout):
                if not nospike:
                    # Step 4: diff -s sim/commit.log sim/spike.log
                    diff_command = "diff -s sim/commit.log sim/spike.log"
                    stdout, stderr = run_command(diff_command)

                    if "Files sim/commit.log and sim/spike.log are identical" in stdout:
                        print(f"Logs match for {filename}.")
                        passed_both.append(filename)
                    else:
                        print(f"Logs differ for {filename}. Diff output:\n{stdout}\n{stderr}")
                        failed_spike.append(filename)  # Mark as failed if diff fails
                else:
                    print(f"Skipped spike and diff for {filename} due to 'nospike'.")
                    passed_both.append(filename)  # Count as passed since no spike or diff was run
            else:
                failed_sim.append(filename)
                print(f"Simulation failed for {filename}. Output:\n{stdout}\nError:\n{stderr}")

        # Step 4: Run custom tests
        if (run_custom):
            compile_command = f"make clean && make compile PROG=../chip/testcode/soc/src/test.c"
            stdout, stderr = run_command(compile_command)
            print(f"Compilation output for ADP_TEST:\n{stdout}\n")

            vc_command = "make vc DIR=soc DEFINE=ADP_TEST"
            stdout, stderr = run_command(vc_command)

            # Check only the last few lines for "Sim Successful"
            if check_sim_successful(stdout):
                passed_both.append("ADP_TEST")  # Count as passed since no spike or diff was run
            else:
                failed_sim.append("ADP_TEST")
                print(f"Simulation failed for ADP_TEST. Output:\n{stdout}\nError:\n{stderr}")

    except FileNotFoundError:
        print(f"File {file_path} not found.")
    except Exception as e:
        print(f"An error occurred while processing testcases: {e}")

    # Return the summary for this file
    return {
        'file': file_path,
        'passed_both': passed_both,
        'failed_spike': failed_spike,
        'failed_sim': failed_sim
    }

def print_summaries(summaries):
    """Print the final summary for all testcases."""
    print("\n=== Final Test Summary ===")
    for summary in summaries:
        print(f"\n=== Summary for {summary['file']} ===")
        print(f"Passed both steps (spike + sim): {', '.join(summary['passed_both']) if summary['passed_both'] else 'None'}")
        print(f"Failed spike step: {', '.join(summary['failed_spike']) if summary['failed_spike'] else 'None'}")
        print(f"Failed sim step: {', '.join(summary['failed_sim']) if summary['failed_sim'] else 'None'}")

if __name__ == "__main__":
    # Check if at least one testcases file is provided as argument
    if len(sys.argv) < 2:
        print(f"Usage: python3 {os.path.basename(__file__)} <testcases_file1> <testcases_file2> ...")
        sys.exit(1)

    summaries = []  # List to collect summaries for each testcases file

    # Iterate over each provided testcases file and process it
    for testcases_file in sys.argv[1:]:
        print(f"\n=== Processing file: {testcases_file} ===")
        summary = process_testcases(testcases_file, 0)
        summaries.append(summary)

    # Run custom test cases
    summary = process_testcases("testsets/test_custom.txt", 1)
    summaries.append(summary)

    # Print all summaries at the end
    print_summaries(summaries)
