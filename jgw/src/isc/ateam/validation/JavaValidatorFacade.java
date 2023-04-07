package isc.ateam.validation;

import java.util.*;
import java.io.*;
import org.hl7.fhir.validation.*;
import org.hl7.fhir.r5.model.*;
import org.hl7.fhir.r5.formats.JsonParser;
import org.hl7.fhir.r5.utils.ToolingExtensions;
import org.hl7.fhir.r5.context.SystemOutLoggingService;
import org.hl7.fhir.r5.elementmodel.Manager.FhirFormat;
import org.hl7.fhir.utilities.validation.ValidationMessage;

public class JavaValidatorFacade
{
    private static ValidationEngine validator;
    private static String IG;
    private static String terminologyServer;
    
    public static void init(String igList, String txServer) throws Throwable
    {
        validator = null;
        IG = null;
        terminologyServer = null;
        try 
        {
            if ((txServer != null) && (txServer.trim().length() == 0)) txServer = null;
            boolean canRunWithoutTerminologyServer = (txServer == null);

            ValidationEngine.ValidationEngineBuilder builder = new ValidationEngine.ValidationEngineBuilder(null, null, "4.0", txServer, null, null, null, canRunWithoutTerminologyServer, new SystemOutLoggingService(), false);
            validator = builder.fromSource("hl7.fhir.r4.core#4.0.1");

            validator.setLevel(org.hl7.fhir.validation.cli.utils.ValidationLevel.ERRORS);

            if (igList != null && igList.length() > 0)
            {
                IgLoader igLoader = validator.getIgLoader();

                String[] igs = igList.split(",");
                for (int i = 0; i < igs.length; i++)
                {
                    igLoader.loadIg(validator.getIgs(), validator.getBinaries(), igs[i], true);
                }
            }
            validator.prepare();

            IG = igList;
            terminologyServer = txServer;
        }
        catch (Throwable e) 
        {
            validator = null;
            IG = null;
            terminologyServer = null;
            throw e;
        }
    }

    public static byte[] validate(String igList, byte[] resourceBytes, String txServer, String profileList) throws Throwable
    {
        if ((validator == null)
            || !igList.equals(IG) 
            || (terminologyServer == null && txServer != null)
            || (terminologyServer != null && txServer == null)
            || (terminologyServer != null && !terminologyServer.equals(txServer)))
        {
            init(igList, txServer);
        }

        String[] profiles = (profileList == null || profileList.length() == 0 ? new String[] {} : profileList.split(","));

        Resource r = validator.validate(resourceBytes, FhirFormat.JSON, Arrays.asList(profiles), new ArrayList<ValidationMessage>());

        return serializeToByteArray(r);
    }

    public static byte[] validateFile(String igList, String resourceFilePath, String txServer, String profileList) throws Throwable
    {
        if ((validator == null)
            || !igList.equals(IG) 
            || (terminologyServer == null && txServer != null)
            || (terminologyServer != null && txServer == null)
            || (terminologyServer != null && !terminologyServer.equals(txServer)))
        {
            init(igList, txServer);
        }

        String[] profiles = (profileList == null || profileList.length() == 0 ? new String[] {} : profileList.split(","));

        Resource r = validator.validate(resourceFilePath, Arrays.asList(profiles));

        return serializeToByteArray(r);
    }

    private static byte[] serializeToByteArray(Resource r) throws Throwable
    {
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        new JsonParser().setOutputStyle(org.hl7.fhir.r5.formats.IParser.OutputStyle.PRETTY).compose(os, r);
        os.close();
        return os.toByteArray();
    }

    public static void main(String[] args) throws Throwable
    {
        String igList = args[0];
        String source = args[1];

        String txServer = null;
        if (args.length > 2) txServer = args[2];

        String profileList = null;
        if (args.length > 3) profileList = args[3];

        init(igList, txServer);

        String[] profiles = (profileList == null || profileList.length() == 0 ? new String[] {} : profileList.split(","));

        Resource r = validator.validate(source, Arrays.asList(profiles));

        System.out.println();
        displayValidationResult(r);
        System.out.println();
        System.out.println(serialize(r));
        System.out.println();
    }

    private static String serialize(Resource r) throws Throwable
    {
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        new JsonParser().setOutputStyle(org.hl7.fhir.r5.formats.IParser.OutputStyle.PRETTY).compose(os, r);
        os.close();
        return os.toString();
    }

    private static void displayValidationResult(Resource r) throws Throwable
    {
        if (r instanceof Bundle)
        {
            System.out.println("Bundle outcome from validator.validate()");
            //for (Bundle.BundleEntryComponent e : ((Bundle) r).getEntry())
            //    ec = ec + displayOperationOutcome((OperationOutcome) e.getResource(), ((Bundle) r).getEntry().size() > 1) + ec;
        }
        else if (r == null)
        {
            System.out.println("No output from validation - nothing to validate");
        }
        else 
        {
            OperationOutcome oo = (OperationOutcome) r;
            int error = 0;
            int warn = 0;
            int info = 0;

            for (OperationOutcome.OperationOutcomeIssueComponent issue : oo.getIssue()) 
            {
                if (issue.getSeverity() == OperationOutcome.IssueSeverity.FATAL || issue.getSeverity() == OperationOutcome.IssueSeverity.ERROR)
                    error++;
                else if (issue.getSeverity() == OperationOutcome.IssueSeverity.WARNING)
                    warn++;
                else
                    info++;
            }
            System.out.println((error == 0 ? "Success" : "*FAILURE*") + ": " + Integer.toString(error) + " errors, " + Integer.toString(warn) + " warnings, " + Integer.toString(info) + " notes");
        }
    }

    private static String getIssueSummary(OperationOutcome.OperationOutcomeIssueComponent issue)
    {
        String loc;
        if (issue.hasExpression())
        {
            int line = ToolingExtensions.readIntegerExtension(issue, ToolingExtensions.EXT_ISSUE_LINE, -1);
            int col = ToolingExtensions.readIntegerExtension(issue, ToolingExtensions.EXT_ISSUE_COL, -1);
            loc = issue.getExpression().get(0).asStringValue() + (line >= 0 && col >= 0 ? " (line " + Integer.toString(line) + ", col" + Integer.toString(col) + ")" : "");
        }
        else if (issue.hasLocation()) 
        {
            loc = issue.getLocation().get(0).asStringValue();
        }
        else 
        {
            int line = ToolingExtensions.readIntegerExtension(issue, ToolingExtensions.EXT_ISSUE_LINE, -1);
            int col = ToolingExtensions.readIntegerExtension(issue, ToolingExtensions.EXT_ISSUE_COL, -1);
            loc = (line >= 0 && col >= 0 ? "line " + Integer.toString(line) + ", col" + Integer.toString(col) : "??");
        }
 
        return "  " + issue.getSeverity().getDisplay() + " @ " + loc + " : " + issue.getDetails().getText();
    }
}