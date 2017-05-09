`./run-cpt10.sh` will run the whole set of experiments.
To launch it you have two choices :

1. The easy way aka from a node inside chameleon (recommended)
2. The adventurer's way aka from your local machine.

> Enos latest documentation : https://enos.readthedocs.io/en/latest/

## From inside chameleon chi@uc

* Provision a new Ubuntu16.04 server that will act as the experiment frontend.
* On this machine create a password-less keypair that will be used for the connection from
  your frontend to the EnOs nodes :

```
frontend) ssh-keygen -t rsa
```
* Add the public part of this key to the available keypairs on horizon the
  dashboard.

* Configure the reservation.yml to reflect your configuration (keyname)

* Clone `enos-scenarios`

```
frontend) git clone https://github.com/BeyondTheClouds/enos-scenarios.git
```

* upload and source your rc file

```
frontend) source BM-CHI-CH-818723-openrc.sh
```

* Launch the `run-cpt10.sh`

```
cd enos-scenarios/wan_chameleon/cpt10
./run-cpt10.sh
```

> See the note below about resources polling

## From outside chameleon chi@uc

* Clone `enos-scenarios`

```
frontend) git clone https://github.com/BeyondTheClouds/enos-scenarios.git
```

* Configure the reservation.yml to reflect your configuration :
  * `keyname`
  * `gateway: true`

* Source your rc file

```
frontend) source BM-CHI-CH-818723-openrc.sh
```

* Launch the `run-cpt10.sh`

```
cd enos-scenarios/wan_chameleon/cpt10
./run-cpt10.sh
```

> See below about the resource polling

> Please read also https://enos.readthedocs.io/en/latest/provider/openstack.html#deployment

# Resource polling

Chameleon provider doesn't implement yet (April 2017) a polling policy that make sure the
ressources are ssh-able before launching Ansible. This will come soon, in a provider agnostic way
and come with some benefits... In the mean time you'll have to wait by yourself
and relaunch the run script (yeah it's stateless !)
