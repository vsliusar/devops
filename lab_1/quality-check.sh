npm run format

npm run lint

npm run test

npm audit

if [ $? -ne 0 ]; then
    echo "Code quality issues were found"
    exit 1
else
    echo "No code quality issues were found"
fi