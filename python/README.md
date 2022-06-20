# Building a Containerized Python Application

## Prerequisites
1. Have a developer environment setup
    1. Option 1 - Install on your local device
        1. Install [Docker](https://docs.docker.com/get-docker/)
        1. Install [httpie](https://httpie.io/cli)
    1. Option 2 - Create a Remote Execution Environment on DigitalOcean
        1. You'll need a DigitalOcean account
        1. Install [Terraform](https://www.terraform.io/downloads) on your local machine
            1. It's a single binary, so extract it and run it
        1. Use the [Terraform file in dev-env]() to standup a prebuilt dev env.

### Instructions

1. Clone the [Workshop Reposotiry](https://github.com/do-community/OSS-2022-Getting-Started-With-Kubernetes)
1. Navigate to the Python Directory
1. Review Code with Mason
    1. 2 API endpoints
        1. **POST** */secrets*
            1. Vars
                1. message - required - The message to encrypt
                1. passphrase - required - The passphrase for the message
                1. expiration_time - optional - How long for the message to persist in seconds. Default is 604800
            1. Returns JSON
                1. Vars
                    1. id - unique ID of the secret for retrieval
                    1. success - Boolean
        1. **POST** */secrets/<id>*
            1. Vars
                1. passphrase - required - The passphrase to unlock the secret
            1. Returns JSON
                1. Vars
                    1. message - The decrypted message
                    1. success - Boolean
    1. If the message doesn't exist, has already been read, or has expired
        ```json
        {
            "message": "This secret either never existed or it was already read",
            "success": "False"
        }
        ```
1. Build the docker container 
    ```bash
    docker build -t ots .
    ```
1. Run the image, you'll be given a Redis DB to connect to
    ```bash
    docker run -p 8080:8080 --env DB_HOST="" --env DB_PORT="" --env DB_PASSWORD="" --env DB_SSL=True ots
    ```
1. Test with `httpie`
    1. Test write 
        ```bash
        http POST localhost:8080/secrets message="YOUR_MESSAGE" passphrase="YOUR_PASSPHRASE"
        ```
        1. Sample Response
        ```json
        {
           "id": "ea54d2701885400cafd0c11279672c8f",
           "success": "True"
        }
        ```
    1. Test read, using the id from above
        ```bash
        http POST localhost:8080/secrets/<id> passphrase="YOUR_PASSPHRASE"
        ```
        1. Sample Response
        ```json
        {
            "message": "Hello there",
            "success": "True"
        }
        ```
    1. Test write with expiration time
        ```
        http POST localhost:8080/secrets message="YOUR MESSAGE" passphrase="YOUR PASSPHRASE" expiration_time=15
        ```
        1. Sample Response
        ```json
        {
            "id": "f91b31c852a84feca81a8a9048e02210",
            "success": "True"
        }
        ```
    1. Test read on expired secret
        ```
        http POST localhost:8080/secrets/f91b31c852a84feca81a8a9048e02210 passphrase="YOUR PASSPHRASE"
        ```
        1. Sample Response
        ```json
        {
            "message": "This secret either never existed or it was already read",
            "success": "False"
        }
        ```
    
