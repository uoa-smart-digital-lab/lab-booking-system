<script lang="ts">
    import Table_Persons from "./lib/Table_Persons.svelte";
    import type { PersonDetails, Person } from "./lib/Graphql.svelte";
    import { Usertype } from "./lib/Graphql.svelte";

    let details: PersonDetails = {
        phone: "123456789",
        email: "here@there"
    }
    let persons: Person[] = [
        {
            upi: "rdav031",
            name: "Roy Davies",
            password: "",
            status: Usertype.ADMIN,
            details: details,
            tokens: 0,
            bookings: null,
            inductions: null
        },
        {
            upi: "fdag1234",
            name: "Fred Dagg",
            password: "",
            status: Usertype.USER,
            details: details,
            tokens: 0,
            bookings: null,
            inductions: null
        }
    ]

</script>

<main>
    <Table_Persons horizontal headings controls bind:persons={persons}/>
</main>

<style>

</style>
