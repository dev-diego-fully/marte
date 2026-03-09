cargo build
rm tests/marte.so
mv target/debug/libmarte.so tests/marte.so
cd tests
busted *_spec.lua
cd ..
