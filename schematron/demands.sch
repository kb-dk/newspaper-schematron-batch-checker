<?xml version='1.0' encoding='UTF-8'?>
<s:schema xmlns:s="http://purl.oclc.org/dsdl/schematron">

    <s:pattern>
        <s:rule context="attribute">
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
            <s:assert test="matches(@name,'^B[0-9]{12}-RT[0-9]+$')">Invalid batch name
                <s:value-of select="@name"/>
            </s:assert>

            <s:assert test="node[ends-with(@name,'/WORKSHIFT-ISO-TARGET')]">WORKSHIFT-ISO-TARGET not found</s:assert>
        </s:rule>

        <!-- WORKSHIFT-ISO-TARGET -->
        <s:rule context="/node[@name=$batchID]/node[@name=concat($batchID,'/WORKSHIFT-ISO-TARGET')]">
            <s:assert test="count(node) != 0">No target files in WORKSHIFT ISO TARGET
                <s:value-of select="node/@name"/>
            </s:assert>

            <s:assert test="count(attribute) = 0">Unexpected file in WORKSHIFT ISO TARGET
                <s:value-of select="attribute/@name"/>
            </s:assert>

            <s:report test="node[not(matches(@name,'^.*/Target-[0-9]{6}-[0-9]{4}$'))]">Unexpected folder in WORKSHIFT ISO TARGET
                <s:value-of select="node/@name"/>
            </s:report>
        </s:rule>

        <!-- WORKSHIFT "IMAGES"-->
        <s:rule context="/node[@name=$batchID]/
        node[@name = concat($batchID,'/WORKSHIFT-ISO-TARGET')]/
        node[matches(@name,'^.*/Target-[0-9]{6}-[0-9]{4}$')]">
            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/>
            </s:assert>

            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>

        <!-- FILM -->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]">
            <!-- Example: 400022028241-14 -->
            <s:let name="filmID" value="@name"/>

            <s:assert test="matches(@name,'/[0-9]{12}-[0-9]+$')">Invalid film name
                <s:value-of select="@name"/>
            </s:assert>

            <!-- FILM-XML, example: adresseavisen1759-400022028241-14.film.xml -->
            <s:assert test="matches(attribute/@name,'.*-[0-9]{12}-[0-9]+[.]film[.]xml$')">Invalid film-xml name
                <s:value-of select="@name"/>
            </s:assert>

            <!-- FILM-ISO-target -->
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
            <s:assert test="matches(attribute/@name, concat(@name,'/',$newspaperName,$editionID,'.edition.xml'))">
                edition.xml not found <s:value-of select="attribute/@name"/>
            </s:assert>
        </s:rule>

        <!-- UNMATCHED -->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node[ends-with(@name,'UNMATCHED')]">
            <s:let name="filmName" value="replace(substring-before(../attribute[1]/@name,'.film.xml'),'^.*/','')"/>
            <s:assert test="matches(node/@name, concat(@name,'/',$filmName,'-[0-9]{4}[A-Z]?'))">
                unexpected unmatched target <s:value-of select="node/@name"/>
            </s:assert>
        </s:rule>

        <!-- FILM-ISO-TARGET -->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node[ends-with(@name,'FILM-ISO-target')]">
            <s:let name="filmName" value="replace(substring-before(../attribute[1]/@name,'.film.xml'),'^.*/','')"/>
            <s:assert test="matches(node/@name, concat(@name,'/',$filmName,'-ISO-[0-9]+'))">
                unexpected iso target <s:value-of select="node/@name"/>
            </s:assert>
        </s:rule>

        <!--"PAGE"-->
        <s:rule context="/node[@name=$batchID]/
                        node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/
                        node[ not(ends-with(@name,'UNMATCHED')) and not(ends-with(@name,'FILM-ISO-target'))]/
                        node[ not(ends-with(@name,'brik'))]">
            <s:let name="editionID" value="parent::node/@name"/>

            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>

            <s:assert test="attribute/@name = concat(@name,'.alto.xml')">Alto not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>

            <s:assert test="attribute/@name = concat(@name,'.mods.xml')">Mods not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>

            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>
        </s:rule>

        <!-- "BRIK" -->
        <s:rule context="/node[@name=$batchID]/
                        node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/
                        node[ not(ends-with(@name,'UNMATCHED')) and not(ends-with(@name,'FILM-ISO-target'))]/
                        node[ ends-with(@name,'brik')]">

            <s:let name="editionID" value="parent::node/@name"/>

            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>

            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/> in <s:value-of select="$editionID"/>
            </s:assert>
        </s:rule>

        <!-- UNMATCHED "images" -->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node[ends-with(@name,'UNMATCHED')]/node">
            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/>
            </s:assert>

            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>

        <!-- FILM-ISO-target "images" -->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node[ends-with(@name,'FILM-ISO-target')]/node">
            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/>
            </s:assert>

            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>

        <!-- jp2 node contents -->
        <s:rule context="/node[@name=$batchID]/node[@name != concat($batchID,'/WORKSHIFT-ISO-TARGET')]/node/node/node">
            <s:assert test="attribute[@name=concat(../@name,'/contents')]">Contents not found for jp2file
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>
    </s:pattern>

</s:schema>
