FROM openjdk:11 AS builder

ENV SRCDIR=/tmp/src
ENV GWDIR=/jgw
ENV PORT=55555

COPY src $SRCDIR

WORKDIR $GWDIR
ADD https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar .

WORKDIR $SRCDIR

RUN javac -classpath $GWDIR/* isc/ateam/fhir/JavaValidatorFacade.java && \
    jar -cvf $GWDIR/JavaValidatorFacade.jar isc/ateam/fhir/JavaValidatorFacade.class && \
    ls -al isc/ateam/fhir

ENV ISC_JARDIR /usr/irissys/dev/java/lib/1.8

COPY --from=intersystemsdc/irishealth-community:latest \
     $ISC_JARDIR/intersystems-jdbc-*.jar \
     $GWDIR/

CMD java -Xrs -Djava.system.class.loader=com.intersystems.gateway.ClassLoader -classpath "${GWDIR}/*" com.intersystems.gateway.JavaGateway $PORT "" "JGW:IRIS:%Java Server" 0.0.0.0 "" 2>&1
