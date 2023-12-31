# Application-Profiles
This project brings (at least partially) the ability of providing [properties files](https://docs.spring.io/spring-boot/docs/current/reference/html/application-properties.html) like Spring Framework but now in whatever Python context.

## How to use it

```bash
pip install application-profiles
```

### Import

```python
from application_profiles import ApplicationProfiles
...
profiles = ApplicationProfiles()
...
a_prop :ApplicationProfiles = profiles.properties['a_prop']

```

### Select the desired profile(s) by using Environment Variable

**One profile**

```bash
export APP_PROFILES=dev
```

**List of profile**

```bash
export APP_PROFILES=dev,red,south
```

### Select the desired profile(s) by constructor argument

**One profile**

```python
profiles = ApplicationProfiles(profiles="dev")
```

**List of profile**

```python
profiles = ApplicationProfiles(profiles="dev,red,south")
```


## How it work?
### 'profiles' Python module
Before moving on, there are several requirements to accomplish, the first one is having in the root of your project a module called `profiles`, where your properties files will be placed.
Like this
```bash
profiles/
    __init__.py
    application.yaml
    application-dev.yaml
    ...
```

### Properties Files
Inside the `profiles` module, you must place all the properties files to be included in your project. There is a convention required to name them, like in Spring, the prefix of all the files must be `application` followed by the name of the desired profile, like for example `dev`, `test` etc., joined by a hyphen `-`, here you go a list of common examples
- `application-dev.yaml`
- `application-prod.yaml`
- `application-int.yaml`

**Important**

The default profile is `application.yaml` (without a profile name), this file is optional but it is consedered the **"default"** profile.

### Load Precedence
This is something crucial for the library, there is a precedence in how the files are loaded.
The profiles files are loaded in the following order:

1.- `default` profile.

2.- All the profiles in the provided order by the `profile` constructor argument.

3.- All the profiles in the provided order by the `APP_PROFILES` environment variable.

Properties are merged in that order, then they are consumables through the `ApplicationProfiles` object.

### How the properties are merged?
This point is extremely important, because there are a couple of restrictions in how this library works

- **Lists** : if there is a variable in more than one profile that contains a list, it is replaced entirely with the corresponding value.

- **Dictionaries**: all dictionaries are scanned in deep replacing coincidences for native raw data types like numbers, strings, booleans. It includes nested dictionaries.

## Run it in local
This project uses `Poetry` , in case you don't have it just run `make install-poetry`

**Create a local env & Install dependencies***
```shell
make install
```

**Run the Tests Suite**
```shell
make test
```