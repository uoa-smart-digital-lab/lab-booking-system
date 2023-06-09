<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table, Table_Col, Table_Row, Table_Body, Table_Head, Table_Foot, Input, Buttons, Button } from "svelte-fomantic-ui";
    import type { PersonDetails } from "./Graphql.svelte";

    export let details: PersonDetails;

    export let horizontal: boolean = false;
    export let headings: boolean = false;
    export let controls: boolean = false;

</script>

<!-- 
PersonDetails = {
    phone: string,
    email: string
}
-->

{#if horizontal}
    <Table ui stackable>
        {#if headings}
            <Table_Head>
                <Table_Row>
                    <Table_Col head>phone</Table_Col>
                    <Table_Col head>email</Table_Col>
                </Table_Row>
            </Table_Head>
        {/if}
        <Table_Body>
            <Table_Row>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={details.phone}/>
                    </Input>
                </Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={details.email}/>
                    </Input>
                </Table_Col>
            </Table_Row>
        </Table_Body>
    </Table>
{:else}
    <Table ui definition>
        <Table_Body>
            <Table_Row>
                <Table_Col>phone</Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={details.phone}/>
                    </Input>
                </Table_Col>
            </Table_Row>
            <Table_Row>
                <Table_Col>email</Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={details.email}/>
                    </Input>
                </Table_Col>
            </Table_Row>
        </Table_Body>
    </Table>
{/if}
    


