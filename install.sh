if command -v doas &> /dev/null; then
    PRIVILEGE="doas"
elif command -v sudo &> /dev/null; then
    PRIVILEGE="sudo"
else
    echo "Neither 'doas' nor 'sudo' found. T-T"
    exit 1
fi

mkdir -p ~/.config/nyash
touch ~/.config/nyash/history.txt
cp nyashrc.rb ~/.config/nyash/nyashrc.rb
$PRIVILEGE chmod +x nyash.rb
$PRIVILEGE mv nyash.rb /usr/local/bin/nyash
