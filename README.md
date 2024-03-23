# Netbound
A safe and fair way to play games with friends over the internet

## ⚡ Quick start

### Setup virtualenv and install dependencies
```powershell
python -m venv server/.venv
server/.venv/Scripts/activate
pip install -r server/requirements.txt
```


### Create SSL certificate and key (requires [`mkcert`](https://github.com/FiloSottile/mkcert))
1. Become a certificate authority
    ```powershell
    mkcert -install
    ```

2. Create a certificate for the server, which falls under our CA
    ```powershell
    cd server/ssl
    mkcert localhost 127.0.0.1 ::1
    cd ../..
    ```

### Setup database
```powershell
alembic revision --autogenerate -m "Initial database"
alembic upgrade head
```

### Run the server
```powershell
python -m server
```