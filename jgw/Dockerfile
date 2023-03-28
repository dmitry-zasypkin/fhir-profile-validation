FROM intersystemsdc/jgw:latest

ARG SRCDIR=/tmp/src
ARG GWDIR=/jgw

COPY src $SRCDIR

WORKDIR $GWDIR
ADD https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar .

WORKDIR $SRCDIR

RUN javac -classpath $GWDIR/* isc/ateam/fhir/JavaValidatorFacade.java && \
    jar -cvf $GWDIR/JavaValidatorFacade.jar isc/ateam/fhir/JavaValidatorFacade.class && \
    ls -al isc/ateam/fhir
