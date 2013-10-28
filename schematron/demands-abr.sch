<?xml version='1.0' encoding='UTF-8'?>
<s:schema xmlns:s="http://purl.oclc.org/dsdl/schematron">

    <!-- Example: B400022028241-RT1 -->
    <s:let name="batchID" value="/node/@name"/>

    <!-- Example: B400022028241-RT1/WORKSHIFT-ISO-TARGET -->
    <s:let name="workshiftISOTarget" value="concat($batchID,'/WORKSHIFT-ISO-TARGET')"/>


    <s:pattern id="batchChecker">
        <s:rule context="/node[@name=$batchID]">
            <s:assert test="matches(@name,'^B[0-9]{12}-RT[0-9]+$')"> Invalid batch name <s:value-of select="@name"/> </s:assert>

            <s:assert test="node[@name = $workshiftISOTarget]"> WORKSHIFT-ISO-TARGET not found </s:assert>
        </s:rule>
    </s:pattern>


    <s:pattern id="workshiftIsoTargetChecker">
        <s:rule context="/node[@name=$batchID]/node[@name=$workshiftISOTarget]">
            <s:assert test="count(node) != 0">No target files in WORKSHIFT ISO TARGET
                <s:value-of select="node/@name"/>
            </s:assert>

            <s:assert test="count(attribute) = 0">Unexpected file in WORKSHIFT ISO TARGET
                <s:value-of select="attribute/@name"/>
            </s:assert>

            <s:report test="node[not(matches(@name,'^.*/Target-[0-9]{6}-[0-9]{4}$'))]">Unexpected folder in WORKSHIFT
                ISO TARGET
                <s:value-of select="node/@name"/>
            </s:report>
        </s:rule>
    </s:pattern>


    <s:pattern id="workshiftImageChecker" is-a="scanChecker">
        <!-- Example parameter for abstract pattern: B400022028241-RT1/WORKSHIFT-ISO-TARGET/Target-000001-0001 -->
        <s:param name="scan" value="/node[@name=$batchID]/
          node[@name = $workshiftISOTarget]/
          node[matches(@name,'^.*/Target-[0-9]{6}-[0-9]{4}$')]"/>
    </s:pattern>


    <s:pattern id="filmChecker">
        <!-- Example film: B400022028241-RT1/400022028241-14 -->
        <s:rule context="/node[@name=$batchID]/node[@name != $workshiftISOTarget]">
            <s:let name="filmID" value="@name"/>

            <s:assert test="matches(@name,'/[0-9]{12}-[0-9]+$')">Invalid film name
                <s:value-of select="@name"/>
            </s:assert>

            <!-- Example film-xml: B400022028241-RT1/400022028241-14/adresseavisen1759-400022028241-14.film.xml -->
            <s:assert test="matches(attribute/@name,'.*-[0-9]{12}-[0-9]+[.]film[.]xml$')">Invalid film-xml name
                <s:value-of select="@name"/>
            </s:assert>

            <!-- Example film-iso-target: B400022028241-RT1/400022028241-14/FILM-ISO-target -->
            <s:assert test="node[@name = concat($filmID,'/FILM-ISO-target')]">FILM-ISO-target not found</s:assert>
        </s:rule>
    </s:pattern>


    <s:pattern id="unmatchedChecker" is-a="inFilmChecker">
        <!-- Example first parameter for abstract pattern: B400022028241-RT1/400022028241-14/UNMATCHED -->
        <s:param name="inFilmPath"
                 value="/node[@name=$batchID]/node[@name != $workshiftISOTarget]/node[ends-with(@name,'UNMATCHED')]"/>
        <s:param name="postPattern" value="'-[0-9]{4}[A-Z]?'"/>
    </s:pattern>


    <s:pattern id="filmIsoTargetChecker" is-a="inFilmChecker">
        <!-- Example first parameter for abstract pattern: B400022028241-RT1/400022028241-14/FILM-ISO-target -->
        <s:param name="inFilmPath"
                 value="/node[@name=$batchID]/node[@name != $workshiftISOTarget]/node[ends-with(@name,'FILM-ISO-target')]"/>
        <s:param name="postPattern" value="'-ISO-[0-9]+'"/>
    </s:pattern>


    <s:pattern id="editionChecker">
        <!-- Example: B400022028241-RT1/400022028241-14/1795-06-15-01 -->
        <s:rule context="/node[@name=$batchID]/
           node[@name != $workshiftISOTarget]/
           node[ not(ends-with(@name,'UNMATCHED')) and not(ends-with(@name,'FILM-ISO-target'))]">

            <!-- TODO Remember to test format of node id here -->
            <s:let name="filmID" value="parent::node/@name"/>
            <s:let name="editionID" value="replace(@name,'^.*/','')"/>

            <!--TODO Test edition format to ensure not unexpected folder -->

            <s:let name="newspaperName"
                   value="replace(replace(substring-before(../attribute[1]/@name,'.film.xml'),'^.*/',''),'[0-9]{12}-[0-9]{2}','')"/>
            <s:assert test="matches(attribute/@name, concat(@name,'/',$newspaperName,$editionID,'.edition.xml'))">
                edition.xml not found
                <s:value-of select="attribute/@name"/>
            </s:assert>
        </s:rule>
    </s:pattern>


    <s:pattern id="editionPageChecker">
        <!-- Example: B400022028241-RT1/400022028241-14/1795-06-15-01/adresseavisen1759-1795-06-15-01-0002 -->
        <s:rule context="/node[@name=$batchID]/
                              node[@name != $workshiftISOTarget]/
                              node[ not(ends-with(@name,'UNMATCHED')) and not(ends-with(@name,'FILM-ISO-target'))]/
                              node[ not(ends-with(@name,'brik'))]">
            <!-- Existence of jp2 node and mix is done globally elsewhere -->
            <s:let name="editionID" value="parent::node/@name"/>
            <s:assert test="attribute/@name = concat(@name,'.alto.xml')">Alto not found in
                <s:value-of select="@name"/>
                in
                <s:value-of select="$editionID"/>
            </s:assert>

            <s:assert test="attribute/@name = concat(@name,'.mods.xml')">Mods not found in
                <s:value-of select="@name"/>
                in
                <s:value-of select="$editionID"/>
            </s:assert>
        </s:rule>
    </s:pattern>


    <!-- This pattern checks scans for: unmatched, film-iso, edition pages and briks -->
    <s:pattern id="allScanChecker" is-a="scanChecker">
        <s:param name="scan"
                 value="/node[@name=$batchID]/node[@name != $workshiftISOTarget]/
                 node/node"/>
    </s:pattern>


    <s:pattern id="checksumExistence">
        <s:rule context="attribute">
            <s:report test="@checksum = 'null'">Checksum not found for <s:value-of select="@name"/></s:report>
        </s:rule>
    </s:pattern>


    <!-- This abstract pattern checks a "scan" i.e. a jp2 node, its contents attribute, and corresponding mix file -->
    <s:pattern abstract="true" id="scanChecker">
        <s:rule context="$scan">
            <s:assert test="attribute/@name = concat(@name,'.mix.xml')">Mix not found in
                <s:value-of select="@name"/>
            </s:assert>

            <s:assert test="node/@name = concat(@name,'.jp2')">jp2 not found in
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>

        <s:rule context="$scan/node">
            <s:assert test="attribute[@name=concat(../@name,'/contents')]">Contents not found for jp2file
                <s:value-of select="@name"/>
            </s:assert>
        </s:rule>
    </s:pattern>


    <s:pattern abstract="true" id="inFilmChecker">
        <s:rule context="$inFilmPath">
            <s:let name="filmName" value="replace(substring-before(../attribute[1]/@name,'.film.xml'),'^.*/','')"/>
            <s:assert test="matches(node/@name, concat(@name,'/',$filmName,$postPattern))">
                unexpected file
                <s:value-of select="node/@name"/>
            </s:assert>
        </s:rule>
    </s:pattern>

</s:schema>
