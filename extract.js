const fs = require('fs');

const data = JSON.parse(fs.readFileSync('api_responses.json', 'utf16le'));

for (const key of Object.keys(data)) {
    const val = data[key];
    console.log(`\n--- Endpoint: ${key} ---`);
    if (typeof val === 'string' && val.startsWith('The remote server returned an error:')) {
        console.log('Error:', val);
    } else {
        if (key === 'reports/progress') {
            console.log(JSON.stringify(val, null, 2).substring(0, 2000));
        } else {
            if (Array.isArray(val)) {
                console.log(`Array of ${val.length} items`);
                if (val.length > 0) console.log('Sample:', JSON.stringify(val[0], null, 2).substring(0, 500));
            } else if (val && typeof val === 'object') {
                console.log('Object keys:', Object.keys(val));
                if (val.data && Array.isArray(val.data)) {
                     console.log(`Data Array of ${val.data.length} items`);
                     if (val.data.length > 0) console.log('Sample data:', JSON.stringify(val.data[0], null, 2).substring(0, 500));
                }
            } else {
                console.log('Value:', val);
            }
        }
    }
}
