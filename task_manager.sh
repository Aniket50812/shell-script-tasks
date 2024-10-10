#!/bin/bash


MAX_CONCURRENT_TASKS=4

RETRY_LIMIT=3

execute_task() {
    local task_name=$1
    local cmd=$2
    local retries=0

    while [[ $retries -lt $RETRY_LIMIT ]]; do
        echo "Starting task: $task_name"
        eval $cmd &
        local pid=$!
        
        wait $pid
        local status=$?

        if [[ $status -eq 0 ]]; then
            echo "Task $task_name completed successfully."
            return 0
        else
            echo "Task $task_name failed with status $status. Retrying... ($((retries + 1))/$RETRY_LIMIT)"
            ((retries++))
        fi
    done

    echo "Task $task_name failed after $RETRY_LIMIT retries."
    return 1
}

run_tasks() {
    local task_dependencies=("$@")
    local background_jobs=()
    local completed_tasks=()

    for task in "${task_dependencies[@]}"; do
        IFS=':' read -r task_name cmd dependencies <<< "$task"   #splits

        for dep in ${dependencies//,/ }; do             ##check depedency
            if ! [[ " ${completed_tasks[*]} " == *" $dep "* ]]; then
                echo "Skipping task $task_name: waiting for dependencies: $dep"
                continue 2
            fi
        done

        execute_task "$task_name" "$cmd"
        if [[ $? -eq 0 ]]; then
            completed_tasks+=("$task_name")
        fi

        
        while [[ $(jobs -r -p | wc -l) -ge $MAX_CONCURRENT_TASKS ]]; do
            sleep 1
        done
    done
    wait
}

tasks=(
    "task1:echo 'Task 1 running':"
    "task2:echo 'Task 2 running':"
    "task3:echo 'Task 3 running':task1"
    "task4:echo 'Task 4 running':task1,task2"
)

run_tasks "${tasks[@]}"
