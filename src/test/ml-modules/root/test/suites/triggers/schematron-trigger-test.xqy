xquery version "1.0-ml";
(: Copyright (c) 2024 Progress/MarkLogic :)
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/trigger/helper" at "/triggers/helper.xqy";

xdmp:trace("sv-test","Schematron-Trigger test"),


test:assert-equal(fn:true(), fn:true(), "Not equal")
