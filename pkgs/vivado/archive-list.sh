echo '['
for archive in $(
    NIXPKGS_ALLOW_UNFREE=1 nix log --impure "$1" \
        | grep 'Start extraction for file:' \
        | grep -v '\.xinstall' \
        | grep -oE '/[a-z_]+_[0-9]+' \
        | sort \
        | uniq
); do
    echo "\"${archive:1}\""
done
echo ']'
