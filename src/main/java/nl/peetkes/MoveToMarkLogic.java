package nl.peetkes;

import com.marklogic.client.DatabaseClient;
import com.marklogic.client.DatabaseClientFactory;
import com.marklogic.client.datamovement.DataMovementManager;
import com.marklogic.client.datamovement.JobTicket;
import com.marklogic.client.datamovement.WriteBatcher;
import com.marklogic.client.document.ServerTransform;
import com.marklogic.client.io.DocumentMetadataHandle;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import javax.xml.namespace.NamespaceContext;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import java.io.File;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Iterator;

public class MoveToMarkLogic {
    final static Logger logger = LoggerFactory.getLogger(MoveToMarkLogic.class);
    private static final String OPERA_OPTIONS_OPDRACHT_BESTANDEN = "/opera/options/opdrachtbestanden";
    private static final String AANLEVERAAR_COLLECTION = "/opera/aanleveraar/%s";
    private static final String LEVERING_COLLECTION = "/opera/levering/%s";
    private static final String BEVOEGDGEZAG_COLLECTION = "/opera/bevoegdgezag/%s";

    public static void main(String[] args) throws Exception {
        if (args.length != 6) {
            logger.info("Usage: MoveToMarkLogic <host> <port> <user> <password> <folder-path> <uriPrefix>");
            System.exit(1);
        }
        final String host = args[0];
        final Integer port = Integer.valueOf(args[1]);
        final String user = args[2];
        final String password = args[3];
        final String folderPath = args[4];
        final String uriPrefix = args[5];

        final DatabaseClient marklogic = DatabaseClientFactory
            .newClient(host, port, new DatabaseClientFactory.DigestAuthContext(user, password));
        final DataMovementManager manager = marklogic.newDataMovementManager();
        final File opdrachtFile = getOpdrachtFile(folderPath);
        final Opdracht opdrachtInfo = getOpdrachtInfo(opdrachtFile);
        final ServerTransform envelopeXML = new ServerTransform("envelope");
        envelopeXML.addParameter("idAanleveraar", opdrachtInfo.getIdAanleveraar())
            .addParameter("idLevering", opdrachtInfo.getIdLevering())
            .addParameter("idBevoegdGezag", opdrachtInfo.getIdBevoegdGezag());
        final WriteBatcher batcher = manager.newWriteBatcher()
            .withJobName("Hello, world!")
            // Configure parallelization and memory tradeoffs
            .withBatchSize(10)
            .withThreadCount(2)
            .withTransform(envelopeXML)
            // Configure listeners for asynchronous lifecycle events
            // Success:
            .onBatchSuccess(batch -> logger.info("Batch {} succeeded", batch.getJobTicket().getJobId()))
            // Failure:
            .onBatchFailure((batch, throwable) -> logger.error("Batch {} failed", batch.getJobTicket().getJobId()));
        final DocumentMetadataHandle metadata = new DocumentMetadataHandle();
        metadata.getCollections()
            .addAll(
                OPERA_OPTIONS_OPDRACHT_BESTANDEN,
                String.format(AANLEVERAAR_COLLECTION, opdrachtInfo.getIdAanleveraar()),
                String.format(LEVERING_COLLECTION, opdrachtInfo.getIdLevering()),
                String.format(BEVOEGDGEZAG_COLLECTION, opdrachtInfo.getIdBevoegdGezag()));
        metadata.withMetadataValue("idAanleveraar", opdrachtInfo.getIdAanleveraar())
            .withMetadataValue("idLevering", opdrachtInfo.getIdLevering())
            .withMetadataValue("idBevoegdGezag", opdrachtInfo.getIdBevoegdGezag());
        Files.walk(Path.of(folderPath))
            .filter(Files::isRegularFile)
            .forEach(file -> {
                try {
                    final String uri = String.format("%s/%s", uriPrefix, file.getFileName());
                    batcher.addAs(uri, metadata, file.toFile());
                } catch (Exception e) {
                    logger.error(e.getMessage());
                }
            });
        final JobTicket ticket = manager.startJob(batcher);
        // Override the default asychronous behavior and make the current
        // thread wait for all documents to be written to MarkLogic.
        batcher.flushAndWait();
        // Finalize the job by its unique handle generated in startJob() above.
        manager.stopJob(ticket);
    }

    private static File getOpdrachtFile(String folderPath) throws Exception {
        File result = null;
        Path folder = Paths.get(folderPath);
        try (DirectoryStream<Path> directoryStream = Files.newDirectoryStream(folder, "opdracht.xml")) {
            for (Path filePath : directoryStream) {
                logger.info("Found file: " + filePath);
                result = filePath.toFile();
                break;
            }
        } catch(Exception e) {
            logger.error(e.getMessage());
        }
        return result;
    }

    private static Opdracht getOpdrachtInfo(File opdrachtFile) {
        Opdracht opdracht = new Opdracht();
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newDefaultInstance();
            factory.setNamespaceAware(true);
            DocumentBuilder builder = factory.newDocumentBuilder();

            Document document = builder.parse(opdrachtFile);
            XPathFactory xPathFactory = XPathFactory.newInstance();
            XPath xPath = xPathFactory.newXPath();
            NamespaceContext nsContext = new NamespaceContext() {
                @Override
                public String getNamespaceURI(String prefix) {
                    if ("lvbb".equals(prefix)) {
                        return "http://www.overheid.nl/2017/lvbb";
                    }
                    if ("lvbb-int".equals(prefix)) {
                        return "http://www.overheid.nl/2020/lvbb-int";
                    }
                    return null;
                }

                @Override
                public String getPrefix(String namespaceURI) {
                    if ("http://www.overheid.nl/2017/lvbb".equals(namespaceURI)) {
                        return "lvbb";
                    }
                    if ("http://www.overheid.nl/2020/lvbb-int".equals(namespaceURI)) {
                        return "lvbb-int";
                    }
                    return null;
                }

                @Override
                public Iterator<String> getPrefixes(String namespaceURI) {
                    logger.info("getPrefixes for: " + namespaceURI);
                    return null;
                }
            };
            xPath.setNamespaceContext(nsContext);

            XPathExpression xpIdAanleveraar = xPath.compile("//lvbb:idAanleveraar");
            XPathExpression xpIdLevering = xPath.compile("//lvbb:idLevering");
            XPathExpression xpIdBevoegdGezag = xPath.compile("//lvbb:idBevoegdGezag");
            NodeList idAl = (NodeList) xpIdAanleveraar.evaluate(document, XPathConstants.NODESET);
            opdracht.setIdAanleveraar(idAl.item(0).getTextContent());
            NodeList idL = (NodeList) xpIdLevering.evaluate(document, XPathConstants.NODESET);
            opdracht.setIdLevering(idL.item(0).getTextContent());
            NodeList idBG = (NodeList) xpIdBevoegdGezag.evaluate(document, XPathConstants.NODESET);
            opdracht.setIdBevoegdGezag(idBG.item(0).getTextContent());

        } catch (Exception e) {
            logger.error(e.getMessage());
        }
        return opdracht;
    }
}
