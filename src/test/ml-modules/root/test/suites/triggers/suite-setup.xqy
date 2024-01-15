xquery version "1.0-ml";
(: Copyright (c) 2024 Progress/MarkLogic :)
import module namespace helper="http://marklogic.com/schema-validator/test/lib/helper" at "/test/lib/helper.xqy";

xdmp:trace("sv-test","Corb Suite-setup"),
helper:disable-triggers();

xdmp:collection-delete("triggers/helper-test");

import module namespace helper="http://marklogic.com/schema-validator/test/lib/helper" at "/test/lib/helper.xqy";
helper:copy-configuration();
