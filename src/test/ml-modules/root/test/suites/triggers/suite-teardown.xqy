xquery version "1.0-ml";
(: Copyright (c) 2024 Progress/MarkLogic :)

xdmp:trace("sv-test","Corb Suite-teardown"),
xdmp:collection-delete("triggers/helper-test");

import module namespace helper="http://marklogic.com/schema-validator/test/lib/helper" at "/test/lib/helper.xqy";
helper:enable-triggers();
