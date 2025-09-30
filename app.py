from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type","text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(b"Hello from arkinfotech24 demo app\n")

if __name__ == "__main__":
    server = HTTPServer(("", 8080), Handler)
    print("Listening on 0.0.0.0:8080")
    server.serve_forever()
