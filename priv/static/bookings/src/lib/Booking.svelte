<!------------------------------------------------------------------------------------------------------
  Use a calendar to manage bookings for a given item
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    // @ts-nocheck - known error with Calendar

	import { Modal } from '@svelteuidev/core';
    import { query } from 'svelte-apollo';
    import { ITEMGET } from './Graphql.svelte';
    import Calendar from '@event-calendar/core';
    import DayGrid from '@event-calendar/day-grid';
    import List from '@event-calendar/list';
    import TimeGrid from '@event-calendar/time-grid';
    import Interaction from '@event-calendar/interaction';
    import ResourceTimeGrid from '@event-calendar/resource-time-grid';
    import ConfirmBooking from './ConfirmBooking.svelte';
    import type { Booking, ItemDetails, Item } from './Graphql.svelte';
    import DeviceDetector from "svelte-device-detector";


    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let itemName : string;               // Details about the item itself
    export let upi : string;                    // Logged in user's UPI
    export let loggedIn : boolean;              // Whether a user is currently logged in
    export let sessionid : string;              // Logged in user's SessionID

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let opened : boolean = false;               // Whether the dialog box is open or not
    let startTime : Date;                       // A starting date
    let endTime : Date;                         // An ending date
    let newStartTime : Date;                    // A new starting date
    let newEndTime : Date;                      // A new ending date
    let updating : boolean = false;             // Whether updating or create a new booking
    let editing : boolean = false;              // Whether editing a booking
    let plugins = [TimeGrid, DayGrid, List, ResourceTimeGrid, Interaction]; // Active Plugns for the calendar
    let ec : any;                               // Reference to the Calendar
    let details : any;                          // Additional booking details


    // The GraphQL query structure for login
    let item : any = query(ITEMGET, { variables: {name: itemName} });

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    const getName = (details : ItemDetails, name : string) : string => details.name ? details.name : name;

    // This is a bit of a hack to create a date that is independent of the timezone as the server itself operates at zero UTC
    // Javascript date functions otherwise add the timezone which then puts the date in the wrong place in the server.
    const createDate = (date: Date) => {
        return (date.getFullYear().toString() + "-" + ((date.getMonth()<9)?"0":"") + (date.getMonth()+1).toString() + "-" + ((date.getDate()<10)?"0":"") + date.getDate().toString() + "T" + ((Math.floor(date.getHours().toString())<10)?"0":"") + Math.floor(date.getHours().toString()).toString() + ":00:00+00:00");
    }

    // Convert the bookings from the API into a format that the calendar can use
    const translateBookingsForCalendar = (bookings : [Booking]) : any => {
        let calendarEvents = [];
        let counter : number = 0;
        bookings.forEach((booking : Booking) => {
            let eventLength = (new Date(booking.endtime) - new Date(booking.starttime)) / (1000 * 3600);

            calendarEvents.push({
                id: counter++,
                start: booking.starttime,
                end: booking.endtime,
                title: booking.person.name + " (" + booking.person.upi + ") " + (booking.details.info ? (" - " + booking.details.info) : ""),
                backgroundColor: loggedIn && (booking.person.upi === upi) ? '#2185d0' : '#cccccc',
                editable: loggedIn && (booking.person.upi === upi),
                startEditable: loggedIn && (booking.person.upi === upi),
                durationEditable: loggedIn && (booking.person.upi === upi),
                allDay: (eventLength > 23),
                extendedProps: booking.details
            });
        })
        return calendarEvents;
    }

    // Close the dialog box (eg after cancel button pressed)
    const closeDialog = () => { item.refetch(); ec.setOption("events", translateBookingsForCalendar($item.data.itemGet.bookings)); ec.unselect(); opened = false; }

    // Called when the update or new booking is successful (and sends the updated item)
    const success = (updatedItem : Item) => { closeDialog(); }

    const newEvent = (info : any) => {
        if(loggedIn) {
            ec.unselect(); 
            updating=false;
            editing=false;
            newStartTime = startTime = createDate(info.start);
            newEndTime = endTime = createDate(info.end);
            details = {info:""};
            opened = true;
        }
    }

    const updateEvent = (info : any) => {
        if (loggedIn) {
            updating=true;
            editing=false;
            newStartTime = createDate(info.event.start);
            startTime = createDate(info.oldEvent.start);
            newEndTime = createDate(info.event.end);
            endTime = createDate(info.oldEvent.end);
            details = info.event.extendedProps;
            opened = true;
        }
    }

    const editEvent = (info : any) => {
        if (loggedIn) {
            updating=false;
            editing=true;
            newStartTime = startTime = createDate(info.event.start);
            newEndTime = endTime = createDate(info.event.end);
            details = info.event.extendedProps;
            opened = true;
        }
    }
</script>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Styles
------------------------------------------------------------------------------------------------------->
<style>

</style>
<!----------------------------------------------------------------------------------------------------->

<!-- start: 'prev,next today',
center: 'title',
end: 'dayGridMonth,timeGridDay'

start: 'prev,next today',
center: 'title',
end: 'dayGridMonth,timeGridWeek' -->


<!------------------------------------------------------------------------------------------------------
Layout
------------------------------------------------------------------------------------------------------->
{#if $item.loading}
    Loading...
{:else if $item.error}
    Error: {$item.error.message}
{:else}
    <Modal size="xs" {opened} on:close={closeDialog} title="Confirm" centered>
        <ConfirmBooking size="xs" {details} {sessionid} {closeDialog} {success} {updating} {editing} {upi} {itemName} {startTime} {endTime} {newStartTime} {newEndTime} />
    </Modal>
    <DeviceDetector showInDevice="mobile">
        <Calendar bind:this={ec} {plugins} options = {{
            scrollTime: '09:00:00',
            views: {
                timeGridDay: {pointer: true},
                dayGridMonth: {pointer: true}
            },
            events: translateBookingsForCalendar($item.data.itemGet.bookings),
            eventResize: updateEvent,
            eventDrop: updateEvent,
            eventClick: editEvent,
            select: newEvent,
            nowIndicator: true,
            editable: false,
            selectable: loggedIn,
            slotMinTime: "06:00:00",
            view: "dayGridMonth"
        }} />
    </DeviceDetector>
    <DeviceDetector showInDevice="desktop">
        <Calendar bind:this={ec} {plugins} options = {{
            scrollTime: '09:00:00',
            views: {
                timeGridWeek: {pointer: true},
                dayGridMonth: {pointer: true}
            },
            events: translateBookingsForCalendar($item.data.itemGet.bookings),
            eventResize: updateEvent,
            eventDrop: updateEvent,
            eventClick: editEvent,
            select: newEvent,
            nowIndicator: true,
            editable: false,
            selectable: loggedIn,
            slotMinTime: "06:00:00",
            view: "dayGridMonth"
        }} />
    </DeviceDetector>
{/if}
<!----------------------------------------------------------------------------------------------------->
