<?xml version='1.0' encoding='UTF-8'?>
<s:schema xmlns:s="http://purl.oclc.org/dsdl/schematron">

    <s:pattern>
        <s:rule context="attribute">
            <!-- Check: Every file must have a checksum -->
            <s:report test="@checksum = 'null'">Checksum not found for
                <s:value-of select="@name"/>
            </s:report>
        </s:rule>
    </s:pattern>


    <s:pattern>
        <s:title>SB Avis-scan file-structure-check</s:title>

        <!-- Example: B400022028241-RT1 -->
        <s:let name="batchID" value="/node/@name"/>

        <!-- BATCH -->
        <s:rule context="/node[@name=$batchID]">
            <!-- Check: Name of outermost folder (batch folder) must have the right format: B[0-9]{12}-RT[0-9]+ -->
            <s:assert test="matches(@name,'^B[0-9]{12}-RT[0-9]+$')">Invalid batch name
                <s:value-of select="@name"/>
            </s:assert>

            <!-- Check: Batch folder must contain a folder called WORKSHIFT-ISO-TARGET -->
            <s:assert test="node[ends-with(@name,'/WORKSHIFT-ISO-TARGET')]">WORKSHIFT-ISO-TARGET not found</s:assert>
        </s:rule>

        <!-- WORKSHIFT-ISO-TARGET -->
        <s:rule context="/node[@name=$batchID]/node[@name=concat($batchID,'/WORKSHIFT-ISO-TARGET')]">
            <!-- Check: WORKSHIFT-ISO-TARGET cannot be empty (must have atleast one node, i.e. DOMS-recognized jp2) -->
            <s:assert test="count(node) != 0">No target files in WORKSHIFT ISO TARGET
                <s:value-of select="node/@name"/>
            </s:assert>

            <!-- Check: WORKSHIFT-ISO-TARGET cannot contain attributes (only nodes, i.e. DOMS-recognized jp2s) -->
            <s:assert test="count(attribute) = 0">Unexpected file in WORKSHIFT ISO TARGET
                <s:value-of select="attribute/@name"/>
            </s:assert>

            <!-- Check: Names (nodes) in WORKSHIFT-ISO-TARGET must be of the right format: Target-[0-9]{6}-[0-9]{4} -->
            <s:report test="node[not(matches(@name,'^.*/Target-[0-9]{6}-[0-9]{4}$'))]">Unexpected folder in WORKSHIFT ISO TARGET
                <s:value-of select="node/@name"/>
            </s:report>
        </s:rule>

        <!-- WORKSHIFT "IMAGES"-->
        <s:rule context="/node[@name=$batchID]/
        node[@name = concat($batchID,'/WORKSHIFT-ISO-TARGET')]/
        node[matches(@name,'^.*/Target-[0-9]{6}-[0-9]{4}$')]">
            <!-- Check: There must exist a file in each WORKSHIFT-ISO-TARGET/Target-[0-9]{6}-[0-9]{4} called Target-[0-9]{6}-[0-9]{4}.mix.xml -->
            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/>
            </s:assert>

            <!-- Check: There must exist a jp2-node in each WORKSHIFT-ISO-TARGET/Target-[0-9]{6}-[0-9]{4} called Target-[0-9]{6}-[0-9]{4}.jp2 -->
            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>

        <!-- FILM -->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]">
            <!-- Example: 400022028241-14 -->
            <s:let name="filmID" value="@name"/>

            <!-- Check: Any folder in BATCH not called WORKSHIFT-ISO-TARGET must have name of format [0-9]{12}-[0-9]+ (a FILM folder) -->
            <s:assert test="matches(@name,'/[0-9]{12}-[0-9]+$')">Invalid film name
                <s:value-of select="@name"/>
            </s:assert>

            <!-- FILM-XML, example: adresseavisen1759-400022028241-14.film.xml -->
            <!-- Check: A file (attribute) in a FILM folder is only allowed if it has a name ending in -[0-9]{12}-[0-9]+[.]film[.]xml -->
            <s:assert test="matches(attribute/@name,'.*-[0-9]{12}-[0-9]+[.]film[.]xml$')">Invalid film-xml name
                <s:value-of select="@name"/>
            </s:assert>

            <!-- FILM-ISO-target -->
            <!-- Check: In BATCH/FILM/ there should be a folder of the name FILM-ISO-target -->
            <s:assert test="node[@name = concat($filmID,'/FILM-ISO-target')]">FILM-ISO-target not found</s:assert>
        </s:rule>

        <!-- EDITION -->
        <s:rule context="/node[@name=$batchID]/
        node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/
        node[ not(ends-with(@name,'UNMATCHED')) and not(ends-with(@name,'FILM-ISO-target'))]">

            <!--TODO Remember to test format of node id here-->
            <s:let name="filmID" value="parent::node/@name"/>
            <s:let name="editionID" value="replace(@name,'^.*/','')"/>

            <!--Test edition format to ensure not unexpected folder-->

            <!--edition.xml is an attribute here-->
            <s:let name="newspaperName"
                   value="replace(replace(substring-before(../attribute[1]/@name,'.film.xml'),'^.*/',''),'[0-9]{12}-[0-9]{2}','')"/>
            <!-- Check: In BATCH/FILM/EDITION/ there must be a file called <newspaperName>-<EDITION>.edition.xml, with correct <> inserts -->
            <s:assert test="matches(attribute/@name, concat(@name,'/',$newspaperName,$editionID,'.edition.xml'))">
                edition.xml not found <s:value-of select="attribute/@name"/>
            </s:assert>
        </s:rule>

        <!-- UNMATCHED -->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node[ends-with(@name,'UNMATCHED')]">
            <s:let name="filmName" value="replace(substring-before(../attribute[1]/@name,'.film.xml'),'^.*/','')"/>
            <!-- Check: jp2 nodes in UNMATCHED must have same name as FILM-XML but end in -[0-9]{4}[A-Z]? instead -->
            <s:assert test="matches(node/@name, concat(@name,'/',$filmName,'-[0-9]{4}[A-Z]?'))">
                unexpected unmatched target <s:value-of select="node/@name"/>
            </s:assert>
        </s:rule>

        <!--FILM-ISO-TARGET -->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node[ends-with(@name,'FILM-ISO-target')]">
            <s:let name="filmName" value="replace(substring-before(../attribute[1]/@name,'.film.xml'),'^.*/','')"/>
            <!-- Check:  -->
            <s:assert test="matches(node/@name, concat(@name,'/',$filmName,'-ISO-[0-9]+'))">
                unexpected iso target <s:value-of select="node/@name"/>
            </s:assert>
        </s:rule>

        <!--"page"-->
        <s:rule context="/node[@name=$batchID]/
                        node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/
                        node[ not(ends-with(@name,'UNMATCHED')) and not(ends-with(@name,'FILM-ISO-target'))]/
                        node[ not(ends-with(@name,'brik'))]">
            <!--Test for existence of mix-->
            <!--Test for child jp2 node-->
            <s:let name="editionID" value="parent::node/@name"/>

            <!-- Check: -->
            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>

            <!-- Check: -->
            <s:assert test="attribute/@name = concat(@name,'.alto.xml')">Alto not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>

            <!-- Check: -->
            <s:assert test="attribute/@name = concat(@name,'.mods.xml')">Mods not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>

            <!-- Check: -->
            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>
        </s:rule>

        <!--"brik"-->
        <s:rule context="/node[@name=$batchID]/
                        node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/
                        node[ not(ends-with(@name,'UNMATCHED')) and not(ends-with(@name,'FILM-ISO-target'))]/
                        node[ ends-with(@name,'brik')]">

            <!--Test for child jp2 node-->
            <s:let name="editionID" value="parent::node/@name"/>

            <!-- Check: -->
            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>

            <!-- Check: -->
            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>
        </s:rule>

        <!--unmatched "images"-->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node[ends-with(@name,'UNMATCHED')]/node">
            <!--Test for existence of mix-->
            <!--Test for child jp2 node-->
            <!-- Check: -->
            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/>
            </s:assert>

            <!-- Check: -->
            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>

        <!--"Film iso target images"-->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node[ends-with(@name,'FILM-ISO-target')]/node">
            <!--Test for existence of mix-->
            <!--Test for child jp2 node-->
            <!-- Check: -->
            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/>
            </s:assert>

            <!-- Check: -->
            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>

        <!--jp2 file-->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node/node/node">
            <!-- Check: -->
            <s:assert test="attribute[@name=concat(../@name,'/contents')]">Contents not found for jp2file
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>
    </s:pattern>

</s:schema>
