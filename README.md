# Drivers CodeQl

This Docker file creates a ready Image to run CodeQl testing on windows driver.
The Image is equipped with latest buildtools and VisualStudio from [microsoft](https://learn.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2022) , choco, and git

It also installs and import microsoft pack for testing CodeQL on windows driver from this [repo](https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools)

# Getting ready

### Working on windows
**Note**:You have first to change docker desktop context to windows containers from docker tray icon.
Then you can easily build the image from docker file
using the following command.

```bash
 docker build -t codeqldriver:latest -m 2GB .
```


### Working on Linux & MacOS

**Step1**: Create Windows Context
You can create windows Context using this code from [repo](https://github.com/StefanScherer/windows-docker-machine/)

```bash
$ git clone https://github.com/StefanScherer/windows-docker-machine
$ cd windows-docker-machine
$ vagrant up --provider virtualbox 2022-box
```
**Step2**:  Change Context
You can change context to windows using the command
```bash

docker context use 2022-box
```
**Step3**:  Build the Image
You can easily build the docker image using the following command
```bash
 docker build -t codeqldriver:latest -m 2GB .
```

# Scanning

**Step1**: Creating and running the container
To create the container with current directory as mount path and name codeqltest

```bash
docker run -v ${PWD}:C:/drivercode --name codeqltest -it codeqldriver
```

**Note**: if you are using MacOS or Linux you can't mount path to the container. 
so you will have to get the code with git or any other tool inside the docker container.
**Step2**: Creating Database
```bash
C:\CodeQL-Home\codeql> .\codeql.exe database create <path to new database> --language=cpp --source=<driver parent directory> --command=<build command or path to build file>
```

Single driver example: 
```bash
C:\CodeQL-Home\codeql> .\codeql.exe database create C:\DriverDatabase --language=cpp --source=C:\drivercode --command="msbuild /t:rebuild C:\drivercode\driver.sln"
```

**Step3** : Analyzing CodeQL Database
To analyze CodeQl database you can run the following command.

```bash
C:\CodeQL-Home\codeql> .\codeql.exe database analyze <path to database> --format=sarifv2.1.0 --output=<"path to output file".sarif> <path to query/suite to run>
```

Example:
```bash
C:\CodeQL-Home\codeql> .\codeql.exe database analyze C:\DriverDatabase --format=sarifv2.1.0 --output=C:\drivercode\DriverAnalysis1.sarif C:\CodeQL-Home\Windows-Driver-Developer-Supplemental-Tools\src\suites\windows_driver_mustfix.qls
```
Currently their are 3 available suites
`ported_driver_ca_checks.qls`
`windows_driver_mustfix.qls`
`windows_driver_recommended.qls`
CodeQL's analysis output is in SARIF format. You can view the output using the [SARIF viewer](https://microsoft.github.io/sarif-web-component/).
