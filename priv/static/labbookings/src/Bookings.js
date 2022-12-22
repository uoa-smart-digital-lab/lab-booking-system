import React, { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import 'react-calendar/dist/Calendar.css';
import { Card, Image, Button, Icon, Header } from 'semantic-ui-react'
import Calendar from 'react-awesome-calendar';

// const datesToAddContentTo = [tomorrow, in3Days, in5Days];

// ----------------------------------------------------------------------------------------------------
// Show the current bookings for an item and make a booking (if the user is allowed to)
// ----------------------------------------------------------------------------------------------------
class Bookings extends Component
{
    constructor(props) {
        super (props);
        this.state = 
        {
        }
    }

    events = [{
        id: 1,
        color: '#fd3153',
        from: '2022-05-02T18:00:00+00:00',
        to: '2022-05-05T19:00:00+00:00',
        title: 'This is an event'
    }, {
        id: 2,
        color: '#1ccb9e',
        from: '2022-05-01T13:00:00+00:00',
        to: '2022-05-05T14:00:00+00:00',
        title: 'This is another event'
    }, {
        id: 3,
        color: '#3694DF',
        from: '2022-05-05T13:00:00+00:00',
        to: '2022-05-05T20:00:00+00:00',
        title: 'This is also another event'
    }];

    handleBooking = () => {
        window.location = this.state.link;
    }

    handleUrl = () => {
        // window.open(this.props.url, '_blank');
        window.location = this.props.url;
    }

    getname = (details, name) => {
        if (details.hasOwnProperty('name'))
        {
            return details.name
        }
        else {
            return name
        }
    }

    // onChange = (nextValue) => {
    //     setValue(nextValue);
    //   }

    onClickTimeLine = (date) => {

    }

    onClickEvent = (event) => {

    }

    render ()
    {
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    Book an item
                </Header>
                <Card centered color='blue'>
                    <Card.Content>
                        <Image src={this.props.image} size='medium'/>
                        <Card.Header as="h2">{this.getname(this.props.details, this.props.name)}</Card.Header>
                        <Card.Description>{this.props.name.toUpperCase()}</Card.Description>
                        <Card.Meta>
                            {this.props.campus}
                        </Card.Meta>
                    </Card.Content>

                    <Card.Content>
                        <Button icon fluid basic onClick={this.handleUrl}>
                            <Icon color='blue' name='external'/>
                            &nbsp; More Details
                        </Button>
                        &nbsp;
                        <Card.Description>
                            Use Calendar below to see and make bookings.
                        </Card.Description>
                    </Card.Content>
                    <Card.Content>
                        <Calendar
                            events={this.events}
                            onClickTimeLine={onClickTimeLine}                            
                            onClickEvent={onClickEvent}                            
                        />
                    </Card.Content>

                </Card>
            </>
        )
    }
}

export default Bookings;
// ----------------------------------------------------------------------------------------------------