FROM intersystemsdc/irishealth-community:latest

ARG JAVA_GATEWAY_PORT
ARG JAVA_GATEWAY_HOST
ARG FHIR_TERMINOLOGY_SERVER
ARG FHIR_IG_LIST
ARG DURABLE_SYS_DIR
ARG FHIR_ENDPOINT
ARG NAMESPACE
ARG FHIR_VERSION
ARG FHIR_CORE_PACKAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

COPY irissession.sh /
RUN chmod +x /irissession.sh

USER ${ISC_PACKAGE_MGRUSER}

COPY src src
COPY Installer.cls Installer.cls

# run iris and initialize
SHELL ["/irissession.sh"]

RUN \
  do $System.OBJ.Load("Installer.cls", "ck") \
  set repoRoot = $system.Process.CurrentDirectory() \
  set namespace = $System.Util.GetEnviron("NAMESPACE") \
  set appKey = $System.Util.GetEnviron("FHIR_ENDPOINT") \
  set strategyClass = "isc.ateam.validation.FHIRValidationInteractionsStrategy" \
  set metadataPackageDirs = $select((+$System.Version.GetMajor() > 2023) || (($System.Version.GetMajor() = 2023) && (+$System.Version.GetMinor() >= 2)):"", 1:$lb(repoRoot _ "/src/search-params-package")) \
  set fhirValidationIGList = $System.Util.GetEnviron("FHIR_IG_LIST") \
  set fhirValidationJavaGatewayServer = $System.Util.GetEnviron("JAVA_GATEWAY_HOST") \
  set fhirValidationJavaGatewayPort = $System.Util.GetEnviron("JAVA_GATEWAY_PORT") \
  set fhirValidationJavaGatewayName = "%Java Server" \
  set fhirValidationTerminologyServer = $System.Util.GetEnviron("FHIR_TERMINOLOGY_SERVER") \
  set fhirVersion = $System.Util.GetEnviron("FHIR_VERSION") \
  set fhirCorePackage = $System.Util.GetEnviron("FHIR_CORE_PACKAGE") \
  set sc = ##class(App.Installer).setup(repoRoot, namespace, appKey, strategyClass, metadataPackageDirs, fhirValidationIGList, fhirValidationJavaGatewayServer, fhirValidationJavaGatewayPort, fhirValidationJavaGatewayName, fhirValidationTerminologyServer, fhirVersion, fhirCorePackage)

# bringing the standard shell back
SHELL ["/bin/bash", "-c"]

USER root
RUN mkdir -p ${DURABLE_SYS_DIR} && chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} ${DURABLE_SYS_DIR}
USER ${ISC_PACKAGE_MGRUSER}
