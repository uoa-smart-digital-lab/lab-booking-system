<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table, Table_Col, Table_Row, Table_Body, Table_Foot, Table_Head, Input, Dropdown, Menu, Item, Button, Icon, Text, Buttons } from "svelte-fomantic-ui";
    import Table_Person from "./Table_Person.svelte";
    import type { Person } from "./Graphql.svelte";

    export let persons: Person[];

    export let horizontal: boolean = false;
    export let headings: boolean = false;
    export let controls: boolean = false;
</script>

<!-- 
Person {
    upi: String!            # The unique University Personal ID
    name: String!           # The person's name
    password: String!       # The password (stored encrypted)
    status: Usertype!       # The person's level of access
    details: Json!          # Any other relevant details (for future expansion)
  
    tokens: Int!            # Number of tokens in the account
  
    inductions: [Item]!     # A list of items this person is inducted for
    bookings: [Booking]!    # A list of current bookings for this person
}
-->

<Table ui _={horizontal?"":"definition"} stackable>
    {#if headings && horizontal}
        <Table_Head>
            <Table_Row>
                <Table_Col head>upi</Table_Col>
                <Table_Col head>name</Table_Col>
                <Table_Col head>password</Table_Col>
                <Table_Col head>status</Table_Col>
                <Table_Col head>details</Table_Col>
                <Table_Col head>tokens</Table_Col>
                <Table_Col head>inductions</Table_Col>
                <Table_Col head>bookings</Table_Col>
            </Table_Row>
        </Table_Head>
    {/if}
    {#each persons as person}
        <Table_Person horizontal bind:person={person}/>
    {/each}
    {#if horizontal}
        {#if controls}
            <Table_Foot class="full-width">
                <Table_Row>
                    <Table_Col colspan="7"></Table_Col>
                    <Table_Col colspan="1">
                        <Buttons ui fluid>
                            <Button ui red>
                                Cancel
                            </Button>
                            <Button ui primary on:click={()=>{console.log(person)}}>
                                Save
                            </Button>
                        </Buttons>
                    </Table_Col>
                </Table_Row>
            </Table_Foot>
        {/if}
    {:else}
        {#if controls}
            <Table_Foot class="full-width">
                <Table_Row>
                    <Table_Col></Table_Col>
                    <Table_Col>
                        <Buttons ui fluid>
                            <Button ui red>
                                Cancel
                            </Button>
                            <Button ui primary on:click={()=>{console.log(person)}}>
                                Save
                            </Button>
                        </Buttons>
                    </Table_Col>
                </Table_Row>
            </Table_Foot>
        {/if}
    {/if}
</Table>    


