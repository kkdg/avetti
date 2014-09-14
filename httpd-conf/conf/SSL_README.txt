openssl genrsa -out temporary.nopass.key 2048
openssl req -new -key temporary.nopass.key -out temporary.csr
openssl x509 -req -days 365 -in temporary.csr -signkey temporary.nopass.key -out temporary.crt

