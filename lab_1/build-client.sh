#!/bin/bash

if [ -f dist/client-app.zip ]; then
    rm dist/client-app.zip
fi

npm install

export ENV_CONFIGURATION=production

npm run build -- --configuration=$ENV_CONFIGURATION

if [ ! -d dist ]; then
    mkdir dist
fi

cd dist
7z a -r -tzip client-app.zip *

cd ..

echo "Build completed"