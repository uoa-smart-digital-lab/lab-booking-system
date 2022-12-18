import React, { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import 'react-calendar/dist/Calendar.css';
import { Card, Image, Button, Icon, Header } from 'semantic-ui-react'
import Calendar from 'react-calendar';

// const datesToAddContentTo = [tomorrow, in3Days, in5Days];

// ----------------------------------------------------------------------------------------------------
// Show the current bookings for an item, ie the maximum number of spaces minus the number of occupants
// ----------------------------------------------------------------------------------------------------
class Bookings extends Component
{
    constructor(props) {
        super (props);
        this.state = 
        {
        }
    }

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

    tileClassName = ({ date, view }) => {
    // Add class to tiles in month view only
    if (view === 'month') {
        // Check if a date React-Calendar wants to check is on the list of dates to add class to
        // if (datesToAddContentTo.find(dDate => isSameDay(dDate, date))) {
        return 'calendar_selected';
        // }
    }
    }

    render ()
    {
        return (
            <>
                <Header centered as="h3" color='blue' block>
                    Item with Bookings
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
                        <Button icon fluid basic onClick={this.handleBooking}>
                            <Icon color='blue' name='calendar'/>
                            &nbsp; Make Booking
                        </Button>
                    </Card.Content>
                    <Card.Content>
                        <Calendar
                            // onChange={onChange}
                            // value={date}
                            tileClassName={this.tileClassName}
                            
                        />
                    </Card.Content>

                </Card>

                {/* <Card.Group centered>
                    <Card color={this.state.num_spaces<=0 ? "red" : "blue"} icon>
                        <Card.Content>
                            <Icon color={this.state.num_spaces<=0 ? "red" : "blue"} name='university' size='massive'/>
                        </Card.Content>
                        <Card.Content>
                            <Card.Header as="h2">
                                {this.props.itemName}
                            </Card.Header>
                        </Card.Content>
                        <Card.Content>
                            <Card.Header as="h4">
                                {this.state.num_spaces} space{this.state.num_spaces === 1? "" : "s"} left.
                            </Card.Header>
                        </Card.Content>
                    </Card>
                </Card.Group> */}
            </>
        )
    }
}

export default Bookings;
// ----------------------------------------------------------------------------------------------------