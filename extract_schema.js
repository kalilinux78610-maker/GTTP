const fs = require('fs');

function extractSchema(obj) {
    if (obj === null) return 'null';
    if (Array.isArray(obj)) {
        if (obj.length === 0) return '[]';
        return `[ ${extractSchema(obj[0])} ]`;
    }
    if (typeof obj === 'object') {
        const schema = {};
        for (const key in obj) {
            schema[key] = extractSchema(obj[key]);
        }
        return schema;
    }
    return typeof obj;
}

try {
    let raw = fs.readFileSync('api_responses_student.json', 'utf16le');
    if (raw.charCodeAt(0) === 0xFEFF) raw = raw.slice(1);
    const data = JSON.parse(raw);
    
    let rawAdmin = fs.readFileSync('api_responses.json', 'utf16le');
    if (rawAdmin.charCodeAt(0) === 0xFEFF) rawAdmin = rawAdmin.slice(1);
    const dataAdmin = JSON.parse(rawAdmin);

    const merged = { ...dataAdmin, ...data };
    
    const schemas = {};
    for (const key in merged) {
        if (typeof merged[key] === 'string' && merged[key].startsWith('The remote server returned an error:')) continue;
        if (typeof merged[key] === 'string' && merged[key].startsWith('The request was aborted:')) continue;
        schemas[key] = extractSchema(merged[key]);
    }
    
    fs.writeFileSync('api_schemas.json', JSON.stringify(schemas, null, 2));
    console.log('Successfully wrote api_schemas.json');
} catch (e) {
    console.error(e);
}
