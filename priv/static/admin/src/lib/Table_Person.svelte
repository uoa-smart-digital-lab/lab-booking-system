<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table, Table_Col, Table_Row, Table_Body, Table_Foot, Table_Head, Input, Dropdown, Menu, Item, Button, Icon, Text, Link } from "svelte-fomantic-ui";
    import type { Person } from "./Graphql.svelte";
    import Table_PersonDetails from "./Table_PersonDetails.svelte";

    export let person: Person;

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
    <Table_Body>
        <Table_Row>
            <Table_Col>
                <Button ui icon red><Icon times/></Button>
            </Table_Col>
            <Table_Col center aligned>
                <Input ui fluid>
                    <Input text bind:value={person.upi}/>
                </Input>
            </Table_Col>
            <Table_Col center aligned>
                <Input ui fluid>
                    <Input text bind:value={person.name}/>
                </Input>
            </Table_Col>
            <Table_Col center aligned>
                <Button ui icon blue tertiary><Icon ui ellipsis horizontal/></Button>
            </Table_Col>
            <Table_Col center aligned>
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
            <Table_Col center aligned>
                <Table_PersonDetails {horizontal} {headings} bind:details={person.details}/>
            </Table_Col>
            <Table_Col center aligned>
                <Input ui fluid>
                    <Input text bind:value={person.tokens}/>
                </Input>
            </Table_Col>
            <Table_Col center aligned>
                <Button ui icon blue tertiary><Icon ui ellipsis horizontal/></Button>
            </Table_Col>
            <Table_Col center aligned>
                <Button ui icon blue tertiary><Icon ui ellipsis horizontal/></Button>
            </Table_Col>
            <Table_Col right aligned>
                <Button ui icon green><Icon check/></Button>
            </Table_Col>
        </Table_Row>
    </Table_Body>
{:else}
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
                    <Input text bind:value={person.password}/>
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
                <Button ui icon blue><Icon ui pen/></Button>
            </Table_Col>
        </Table_Row>
        <Table_Row>
            <Table_Col>bookings</Table_Col>
            <Table_Col>
                <Button ui icon blue><Icon ui pen/></Button>
            </Table_Col>
        </Table_Row>
    </Table_Body>
{/if}
    


