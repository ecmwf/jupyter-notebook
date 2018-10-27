# Jupyter Notebook image with ECMWF software installed

This is a Docker container image based on
[jupyter/base-notebook:6c85e4b43a26](https://hub.docker.com/r/jupyter/base-notebook/),
including the following ECMWF software:

* Magics++ 3.3.0.1
* ecCodes 2.9.0
* Metview 5.2.1

It also included the following Python packages from ECMWF:

* cdsapi 0.1.1
* cfgrib 0.9.2
* ecmwf-api-client 1.4.2
* metview 0.8.6


## Running this image

The following will start a Jupyter Notebook listening on port 8888:

```
$ docker run --publish 8888:8888 ecmwf/jupyter-notebook:latest
```

If you want to be able to read (and save!) notebooks from a directory
(like `/my/notebooks`, for instance), you should mount it in the
container under `/home/jovyan/work`, so that the Jupyter kernel finds them:

```
$ docker run --publish 8888:8888 \
    --volume /my/notebooks:/home/jovyan/work \
      ecmwf/jupyter-notebook:latest
```


## Fetching data from ECMWF's API

If you do not have an ECMWF account,
[register](https://apps.ecmwf.int/registration/). You will receive a
confirmation email.

Once you have received your account and password from ECMWF, [log
in](https://apps.ecmwf.int/auth/login/) into ECMWF's website.

You then need an API key --- get it
[here](https://api.ecmwf.int/v1/key/) and save it to `~/.ecmwfapirc`.

Finally you need to make your ECMWF API key visible to the Jupyter
container:

```
$ docker run --publish 8888:8888 \
    --volume /my/notebooks:/home/jovyan/work \
    --volume ${HOME}/.ecmwfapirc:/home/jovyan/.ecmwfapirc:ro \
      ecmwf/jupyter-notebook:latest
```
