#!/bin/bash
function install_package() {
    local pkg_name=$1
    sudo apt-get install $pkg_name
    


}
function update_package(){
    local pkg_name=$1
    sudo apt-get install --only-upgarde $pkg_names


}



function remove_package() {       #remove with dependency
    local pkg_name=$1
    sudo apt-get autoremove $pkg_name
    
}

function list_installed_packages() {
    echo "Installed Packages:"
    cat "$INSTALLED_LIST"

    sudo apt --installed list
}

function main() {
    case $1 in
        install)
            install_package $2 
            ;;
        remove)
            remove_package $2 
            ;;
        update)
            update_package $2  
            ;;    
        list)
            list_installed_packages
            ;;
        *)
            echo "Usage: $0 {install|remove|list} [package_name] [package_version]"
            exit 1
            ;;
    esac
}

main "$@"
