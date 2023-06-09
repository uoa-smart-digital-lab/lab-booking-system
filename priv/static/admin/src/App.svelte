<script lang="ts">
    import Table_Person from "./lib/Table_Person.svelte";
    import type { PersonDetails, Person } from "./lib/Graphql.svelte";
    import { Usertype } from "./lib/Graphql.svelte";

    let details: PersonDetails = {
        phone: "123456789",
        email: "here@there"
    }
    let person: Person = {
        upi: "rdav031",
        name: "Roy Davies",
        status: Usertype.ADMIN,
        details: details,
        tokens: 0,
        bookings: null,
        inductions: null
    }
    let password="";

</script>

<main>
    <Table_Person horizontal bind:person={person} bind:password={password}/>
</main>

<style>

</style>
