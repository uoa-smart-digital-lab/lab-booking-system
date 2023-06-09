<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table, Table_Col, Table_Row, Table_Body, Table_Foot, Table_Head, Input, Dropdown, Menu, Item, Button, Icon, Text, Buttons } from "svelte-fomantic-ui";
    import type { Person } from "./Graphql.svelte";
    import Table_PersonDetails from "./Table_PersonDetails.svelte";

    export let person: Person;

    export let password: string="";

    export let horizontal: boolean = false;
    export let headings: boolean = false;
    export let controls: boolean = false;

    console.log(person);
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

{#if horizontal}
    <Table ui stackable>
        {#if headings}
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
        <Table_Body>
            <Table_Row>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={person.upi}/>
                    </Input>
                </Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={person.name}/>
                    </Input>
                </Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={password}/>
                    </Input>
                </Table_Col>
                <Table_Col>
                    <Dropdown ui fluid selection selected={person.status.toString()} on:change={(item) => {person.status=Number(item.detail.value)}}>
                        <Input hidden bind:value={person.status}/>
                        <Icon dropdown/>
                        <Text default>Select Status</Text>
                        <Menu fluid>
                            <Item value="0">student</Item>
                            <Item value="1">staff</Item>
                            <Item value="2">admin</Item>
                        </Menu>
                    </Dropdown>
                </Table_Col>
                <Table_Col>
                    <Table_PersonDetails {horizontal} {controls} {headings} bind:details={person.details}/>
                </Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={person.tokens}/>
                    </Input>
                </Table_Col>
                <Table_Col>
                    <Button ui fluid>inductions ...</Button>
                </Table_Col>
                <Table_Col>
                    <Button ui fluid>bookings ...</Button>
                </Table_Col>
            </Table_Row>
        </Table_Body>
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
    </Table>
{:else}
    <Table ui definition stackable>
        <Table_Body>
            <Table_Row>
                <Table_Col>upi</Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={person.upi}/>
                    </Input>
                </Table_Col>
            </Table_Row>
            <Table_Row>
                <Table_Col>name</Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={person.name}/>
                    </Input>
                </Table_Col>
            </Table_Row>
            <Table_Row>
                <Table_Col>password</Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={password}/>
                    </Input>
                </Table_Col>
            </Table_Row>
            <Table_Row>
                <Table_Col>status</Table_Col>
                <Table_Col>
                    <Dropdown ui fluid selection selected={person.status.toString()} on:change={(item) => {person.status=Number(item.detail.value)}}>
                        <Input hidden bind:value={person.status}/>
                        <Icon dropdown/>
                        <Text default>Select Status</Text>
                        <Menu fluid>
                            <Item value="0">student</Item>
                            <Item value="1">staff</Item>
                            <Item value="2">admin</Item>
                        </Menu>
                    </Dropdown>
                </Table_Col>
            </Table_Row>
            <Table_Row>
                <Table_Col>name</Table_Col>
                <Table_Col>
                    <Table_PersonDetails bind:details={person.details}/>
                </Table_Col>
            </Table_Row>
            <Table_Row>
                <Table_Col>tokens</Table_Col>
                <Table_Col>
                    <Input ui fluid>
                        <Input text bind:value={person.tokens}/>
                    </Input>
                </Table_Col>
            </Table_Row>
            <Table_Row>
                <Table_Col>inductions</Table_Col>
                <Table_Col>
                    <Button ui fluid>inductions ...</Button>
                </Table_Col>
            </Table_Row>
            <Table_Row>
                <Table_Col>bookings</Table_Col>
                <Table_Col>
                    <Button ui fluid>bookings ...</Button>
                </Table_Col>
            </Table_Row>
        </Table_Body>
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
    </Table>
{/if}
    


