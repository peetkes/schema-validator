xquery version "1.0-ml";

declare option xdmp:mapping "false";

declare variable $URI external;

xdmp:trace("koop-corb", "Calling Corb schematron transform on URI: " || $URI)