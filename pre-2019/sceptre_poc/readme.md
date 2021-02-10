# Evaluating Scepter for Cloud Formation templates


### Using a Virtual Environment for python
It is recommended to use a virtual environment for the python modules used. Detailed information on what a Virtual Env is [Use this link](https://docs.python-guide.org/dev/virtualenvs/)
Scepter has been installed for this project as a virtual module. This is essentially the same as a node module. Installing them locally avoids the risk of installing and maintaining project specific node modules globally.

#### Installing Virtualenv
```bash
$ pip3 install virtualenv
$ virtualenv --version
```

#### creating a virtualenv
```bash
$ cd sceptre_poc
$ virtualenv -p /usr/local/bin/python sceptre_env
```

Once this has been done start the virtualenv using the below command:
```bash
$ source sceptre_poc/bin/activate
```
and then install the required modules which will now be installed local to your project. You can do this using pip.
```bash
pip install -U sceptre
```
simply type `deactivate` to come out of the virtual environment

### Reference Links
[Sceptre github link](https://github.com/cloudreach/sceptre/tree/master)