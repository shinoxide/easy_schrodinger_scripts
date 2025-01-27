#!/bin/bash

# Script to generate and submit a PBS job script on Lengau Cluster for Desmond MDS report

# Get the current working directory
working_directory=$(pwd)

# Check if the current directory is /home
if [[ "$working_directory" == "/home"* ]]; then
    echo "Error: /home users are not allowed. Please use a directory under /mnt/lustre/users."
    exit 1
fi

# input prompts
echo "Enter project group name (e.g., CBBI1515):"
read project_group
echo "Enter cms file name - that is the -out.cms file (e.g., desmond_md_job_1-out.cms):"
read input_file

# Schrodinger versions
valid_versions=(
    "2019-4"
    "2020-1"
    "2020-3"
    "2020-4"
    "2021-1"
    "2021-2"
    "2021-4"
    "2022-1"
    "2022-4"
    "2023-2"
)

while true; do
    echo "Enter Schrodinger module version (valid options: ${valid_versions[*]}):"
    read schrodinger_version
    if [[ " ${valid_versions[*]} " == *" ${schrodinger_version} "* ]]; then
        break
    else
        echo "Invalid version. Please enter a valid Schrodinger module version."
    fi
done

# Prompt for protein value
echo "Enter protein option (auto or asl). choose auto if you're not sure and asl to define sets of atoms:"
read prot_option
if [ "$prot_option" == "auto" ]; then
    prot_value="\"(protein)\""
elif [ "$prot_option" == "asl" ]; then
    echo "Provide ASL for protein:"
    read prot_value
    prot_value="\"$prot_value\""
else
    echo "Invalid protein option. Exiting."
    exit 1
fi

# Prompt for ligand value
echo "Enter ligand option (auto or asl). choose auto if you're not sure and asl to define sets of atoms:"
read lig_option
if [ "$lig_option" == "auto" ]; then
    lig_value="\"auto\""
elif [ "$lig_option" == "asl" ]; then
    echo "Provide ASL for -lig:"
    read lig_value
    lig_value="\"$lig_value\""
else
    echo "Invalid -lig option. Exiting."
    exit 1
fi

echo "Enter walltime (e.g., 5:30 for 5 hours and 30 minutes):"
read walltime_input
walltime="${walltime_input}:00"

# Create directory and ensure existing directory is not overwritten
base_data_dir="data_${input_file%-out.cms}"
data_dir="${base_data_dir}"
counter=2

while [ -d "${working_directory}/${data_dir}" ]; do
    data_dir="data${counter}_${input_file%-out.cms}"
    counter=$((counter + 1))
done

mkdir -p "${working_directory}/${data_dir}"

# Create PBS script
output_pbs="${working_directory}/report_job.pbs"

cat > "$output_pbs" <<EOL
#!/bin/bash
#PBS -l select=1:ncpus=1:mpiprocs=1
#PBS -P ${project_group}
#PBS -q serial
#PBS -l walltime=${walltime}
#PBS -o ${working_directory}/pbs.out
#PBS -e ${working_directory}/pbs.err
ulimit -s unlimited

ssh login1
module purge
module add chpc/schrodinger/${schrodinger_version}

cd ${working_directory}

\$SCHRODINGER/run event_analysis.py analyze -prot ${prot_value} -lig ${lig_value} -out ${input_file%-out.cms} ${input_file}

\$SCHRODINGER/run analyze_simulation.py ${input_file} ${input_file%-out.cms}_trj ${input_file%-out.cms}-out.eaf ${input_file%-out.cms}-in.eaf

\$SCHRODINGER/run event_analysis.py report -pdf ./${data_dir}/${input_file%-out.cms}.pdf -data -plots -data_dir ./${data_dir}/ ${input_file%-out.cms}-out.eaf -HOST localhost:1 -TMPLAUNCHDIR -JOBNAME "report_${input_file%-out.cms}"

rm ${working_directory}/${data_dir}/P-SSE_Timeline.svg 
EOL

# Output
echo "PBS script generated at: $output_pbs"
echo "Data directory created at: ${working_directory}/${data_dir}"

# Submit the job right away?
echo "Do you want to submit the job right away? (y/n):"
read submit_choice

if [[ "$submit_choice" == "y" ]]; then
    qsub "$output_pbs"
    echo "Job has been submitted."
elif [[ "$submit_choice" == "n" ]]; then
    echo "Exiting without submitting the job. To run the job, use the command:"
    echo "qsub report_job.pbs"
else
    echo "Invalid input. Exiting."
    exit 1
fi
