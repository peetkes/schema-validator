xquery version "1.0-ml";
(: Copyright (c) 2024 Progress/MarkLogic :)
import module namespace test="http://marklogic.com/test" at "/test/test-helper.xqy";
import module namespace helper="http://marklogic.com/schema-validator/corb/helper" at "/corb/helper.xqy";

xdmp:trace("sv-test","Schema-Corb test"),


test:assert-equal(fn:true(), fn:true(), "Not equal")
