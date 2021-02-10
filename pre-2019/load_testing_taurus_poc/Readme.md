# Evaluating Taurus web based load tests


### Running on a Docker Image

We recommend using a docker image to run the tests so that you dont have to explicitly install the tool on your local machine. Use the below command by updating the config and artifact directory relative to your machine.

```
docker run -it --rm -v yout-tests-directory:/bzt-configs -v your-artifact-directory:/tmp/artifacts blazemeter/taurus quick-test.yml

```

