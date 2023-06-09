<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table, Table_Head. Table_Col, Table_Row, Table_Body, Input } from "svelte-fomantic-ui";
    import type { Person } from "./Graphql.svelte";

    export let person:Person;
</script>

<!-- type Person {
    upi: String!            # The unique University Personal ID
    name: String!           # The person's name
    password: String!       # The password (stored encrypted)
    status: Usertype!       # The person's level of access
    details: Json!          # Any other relevant details (for future expansion)
  
    tokens: Int!            # Number of tokens in the account
  
    inductions: [Item]!     # A list of items this person is inducted for
    bookings: [Booking]!    # A list of current bookings for this person
  }  -->


  <Table ui definition>
    <Table_Body>
        <Table_Row>
            <Table_Col>upi</Table_Col>
            <Table_Col>
                <Input ui text bind:value={person.upi}/>
            </Table_Col>
        </Table_Row>
        <Table_Row>
            <Table_Col>name</Table_Col>
            <Table_Col>
                <Input ui text bind:value={person.name}/>
            </Table_Col>
        </Table_Row>
        <Table_Row>
            <Table_Col>status</Table_Col>
            <Table_Col>
                <Input ui password bind:value={person.password}/>
            </Table_Col>
        </Table_Row>
    </Table_Body>
</Table>
    


