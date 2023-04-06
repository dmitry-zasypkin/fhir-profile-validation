FROM intersystemsdc/irishealth-community:latest

ARG JAVA_GATEWAY_PORT
ARG JAVA_GATEWAY_HOST
ARG FHIR_TERMINOLOGY_SERVER
ARG FHIR_IG_LIST
ARG DURABLE_SYS_DIR

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
  set namespace = "FHIRSERVER" \
  set appKey = "/fhir-validation" \
  set strategyClass = "isc.ateam.fhir.validation.FHIRValidationInteractionsStrategy" \
  set metadataPackages = $lb("hl7.fhir.r4.core@4.0.1") \
  set fhirValidationIGList = $System.Util.GetEnviron("FHIR_IG_LIST") \
  set fhirValidationJavaGatewayServer = $System.Util.GetEnviron("JAVA_GATEWAY_HOST") \
  set fhirValidationJavaGatewayPort = $System.Util.GetEnviron("JAVA_GATEWAY_PORT") \
  set fhirValidationTerminologyServer = $System.Util.GetEnviron("FHIR_TERMINOLOGY_SERVER") \
  set sc = ##class(App.Installer).setup(repoRoot, namespace, appKey, strategyClass, metadataPackages, fhirValidationIGList, fhirValidationJavaGatewayServer, fhirValidationJavaGatewayPort, fhirValidationTerminologyServer)

# bringing the standard shell back
SHELL ["/bin/bash", "-c"]

USER root
RUN mkdir -p ${DURABLE_SYS_DIR} && chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} ${DURABLE_SYS_DIR}
USER ${ISC_PACKAGE_MGRUSER}
