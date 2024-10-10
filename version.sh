#!/bin/bash

REPO_DIR=".vcs"
            
# Initialize the repository
init() {
    if [ -d "$REPO_DIR" ]; then
        echo "Repository already initialized."
        return
    fi

    mkdir "$REPO_DIR"                    #version control
    mkdir "$REPO_DIR/commits"
    touch "$REPO_DIR/log.txt"
    echo "Initialized empty version control system."
}

# Commit changes
commit() {
    if [ ! -d "$REPO_DIR" ]; then
        echo "Repository not initialized. Run ./vcs.sh init"
        return
    fi

    if [ $# -ne 1 ]; then     #number of arg pass to fun
        echo "Usage: ./vcs.sh commit <commit_message>"
        return
    fi

    COMMIT_MESSAGE="$1"
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    COMMIT_DIR="$REPO_DIR/commits/$TIMESTAMP"

    mkdir "$COMMIT_DIR"

#   checking regular file from current directory
    for file in *; do
        if [ -f "$file" ]; then
            ln "$file" "$COMMIT_DIR/$file"
        fi
        # saves the state of the files at the time of the commit.
    done

    #append
    echo "$TIMESTAMP: $COMMIT_MESSAGE" >> "$REPO_DIR/log.txt"
    echo "Changes committed with message: $COMMIT_MESSAGE"
}


history() {
    if [ ! -d "$REPO_DIR" ]; then
        echo "Repository not initialized."
        return
    fi

    cat "$REPO_DIR/log.txt"
}


checkout() {
    if [ ! -d "$REPO_DIR" ]; then
        echo "Repository not initialized."
        return
    fi

    if [ $# -ne 1 ]; then
        echo "Usage: ./vcs.sh checkout <timestamp>"
        return
    fi

    TIMESTAMP="$1"      
    COMMIT_DIR="$REPO_DIR/commits/$TIMESTAMP"

    if [ ! -d "$COMMIT_DIR" ]; then
        echo "No such commit: $TIMESTAMP"
        echo "Available commits:"
        ls "$REPO_DIR/commits" || echo "No commits found."
        return
    fi

    # Restore files         
    for file in "$COMMIT_DIR"/*; do
        if [ -f "$file" ]; then
            cp -r "$file" .       #copies from commit back to cwd for
        fi
    done

    echo "Checked out files from commit: $TIMESTAMP"
}


# Main script logic to handle commands
case "$1" in
    init)
        init
        ;;
    commit)
        commit "$2"
        ;;
    history)
        history
        ;;
    checkout)
        checkout "$2"
        ;;
    *)
        echo "Usage: ./vcs.sh {init|commit|history|checkout}"
        ;;
esac
