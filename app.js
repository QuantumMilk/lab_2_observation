const mysql = require("mysql2");

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'admin', // Убедитесь, что пароль верен
    database: 'StarObservatory'
});

connection.connect(function(err){
    if (err) {
        return console.error("Ошибка: " + err.message);
    }
    console.log("Подключение к серверу MySQL успешно установлено");
});

const path = require('path');
const fs = require('fs');
const qs = require('querystring');
const http = require('http');

function reqPost(request, response) {
    if (request.method === 'POST') {
        let body = '';

        request.on('data', function (data) {
            body += data;
        });

        request.on('end', function () {
            const post = qs.parse(body);
            const sInsert = `CALL UpdateSector("${post['col1']}", 3.4, 5, 30, 2, 28, "New sector")`;
            connection.query(sInsert, (err, results, fields) => {
                if (err) {
                    console.error("Ошибка при выполнении процедуры: " + err.message);
                    return;
                }
                console.log('Данные успешно добавлены');
                renderPage(response);
            });
        });
    } else {
        renderPage(response);
    }
}

function renderPage(response) {
    const filePath = path.join(__dirname, 'select.html');
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            response.writeHead(500, {'Content-Type': 'text/plain'});
            response.write('Error loading page');
            response.end();
            return;
        }

        connection.query('SELECT * FROM Sector', (err, results) => {
            if (err) {
                console.error("Ошибка при выполнении SELECT: " + err.message);
                response.writeHead(500, {'Content-Type': 'text/plain'});
                response.write('Error retrieving data');
                response.end();
                return;
            }

            let tableRows = '';
            if (results.length > 0) {
                tableRows += '<tr>';
                Object.keys(results[0]).forEach(key => {
                    tableRows += `<th>${key}</th>`;
                });
                tableRows += '</tr>';

                results.forEach(row => {
                    tableRows += '<tr>';
                    Object.values(row).forEach(value => {
                        tableRows += `<td>${value}</td>`;
                    });
                    tableRows += '</tr>';
                });
            }
            data = data.replace('@tr', tableRows);

            connection.query('SELECT VERSION() AS ver', (err, results) => {
                if (err) {
                    console.error("Ошибка при выполнении SELECT VERSION(): " + err.message);
                    response.writeHead(500, {'Content-Type': 'text/plain'});
                    response.write('Error retrieving database version');
                    response.end();
                    return;
                }
                const dbVersion = results[0].ver;
                data = data.replace('@ver', dbVersion);

                response.writeHead(200, {'Content-Type': 'text/html'});
                response.write(data);
                response.end();
            });
        });
    });
}

const server = http.createServer((req, res) => {
    reqPost(req, res);
});

const hostname = '127.0.0.1';
const port = 3000;
server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});
