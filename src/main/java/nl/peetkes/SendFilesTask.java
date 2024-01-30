package nl.peetkes;

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
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.Iterator;
import java.util.Optional;

public class SendFilesTask {
    public static void main(String[] args) throws Exception {
        if (args.length != 5) {
            System.err.println("Usage: SendFilesTask <endpoint-url> <user> <password> <folder-path> <uriPrefix>");
            System.exit(1);
        }
        final String endpointUrl = args[0];
        final String user = args[1];
        final String password = args[2];
        final String folderPath = args[3];
        final String uriPrefix = args[4];

        HttpClient httpClient = HttpClient.newHttpClient();
        File opdrachtFile = getOpdrachtFile(folderPath);
        Opdracht opdrachtInfo = getOpdrachtInfo(opdrachtFile);
        String queryParams = createQueryParams(opdrachtInfo);
        Files.walk(Path.of(folderPath))
            .filter(Files::isRegularFile)
            .forEach(file -> {
                try {
                    String uriParam = uriPrefix + "/" + file.getFileName();
                    sendFile(httpClient,buildUri(endpointUrl, uriParam, queryParams), user, password, file.toFile(), opdrachtInfo);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
    }

    private static URI buildUri(String endpointUrl, String uri, String params) {
        StringBuilder queryParams = new StringBuilder("uri=")
            .append(uri);
        if (params.isEmpty()) {
            return URI.create(endpointUrl + "?" + queryParams.toString());
        } else {
            queryParams.append(params);
            return URI.create(endpointUrl + "?" + queryParams.toString());
        }
    }

    private static String createQueryParams(Opdracht opdrachtInfo)  {
        StringBuilder result = new StringBuilder("&collection=/opera/options/aanlevering")
            .append("&collection=/opera/oin/").append(opdrachtInfo.getIdAanleveraar())
            .append("&collection=/opera/idlevering/").append(opdrachtInfo.getIdLevering())
            .append("&collection=/opera/bevoegdgezag/").append(opdrachtInfo.getIdBevoegdGezag())
            .append("&value:aanleveraar=").append(opdrachtInfo.getIdAanleveraar())
            .append("&value:levering=").append(opdrachtInfo.getIdLevering())
            .append("&value:bevoegdgezag=").append(opdrachtInfo.getIdBevoegdGezag())
            .append("&transform=envelope")
            .append("&trans:aanleveraar=").append(opdrachtInfo.getIdAanleveraar())
            .append("&trans:levering=").append(opdrachtInfo.getIdLevering())
            .append("&trans:bevoegdgezag=").append(opdrachtInfo.getIdBevoegdGezag());
        return result.toString();
    }

    private static void sendFile(HttpClient httpClient, URI endpoint, String user, String password, File file, Opdracht opdrachtInfo) throws Exception {
        String auth = user + ":" + password;
        String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes());
        String contentType = determineContentType(file.getName());
        HttpRequest request = HttpRequest.newBuilder()
            .uri(endpoint)
            .header("Authorization", "Basic " + encodedAuth)
            .header("Content-Type", contentType)
            .PUT(HttpRequest.BodyPublishers.ofFile(file.toPath()))
            .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println("File: "+ file.getName() + ", Response Code: "+ response.statusCode());
    }

    private static String determineContentType(String fileName) {
        String extension = Optional.ofNullable(fileName)
            .filter(f -> f.contains("."))
            .map(f -> f.substring(fileName.lastIndexOf(".") + 1)).orElse("binary");
        String contentType;
        switch(extension) {
            case "xml": contentType = "application/xml"; break;
            case "gml": contentType = "application/gml+xml"; break;
            default: contentType = "application/x-binary";
        }
        return contentType;
    }
    private static File getOpdrachtFile(String folderPath) throws Exception {
        File result = null;
        Path folder = Paths.get(folderPath);
        try (DirectoryStream<Path> directoryStream = Files.newDirectoryStream(folder, "opdracht.xml")) {
            for (Path filePath : directoryStream) {
                System.out.println("Found file: " + filePath);
                result = filePath.toFile();
                break;
            }
        } catch(Exception e) {
            e.printStackTrace();
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
                    System.out.println("getPrefixes for: " + namespaceURI);
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
            e.printStackTrace();
        }
        return opdracht;
    }
}
