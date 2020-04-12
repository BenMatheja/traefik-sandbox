#/bin/bash
sed -i -- 's/RANDOM1/'$(openssl rand -hex 16)'/g' .env
sed -i -- 's/RANDOM2/'$(openssl rand -hex 16)'/g' .env
sed -i -- 's/RANDOM3/'$(openssl rand -hex 16)'/g' .env
sed -i -- 's/RANDOM4/'$(openssl rand -hex 16)'/g' .env
sed -i -- 's/RANDOM5/'$(openssl rand -hex 16)'/g' .env