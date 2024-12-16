# Use an official Ruby image as the base image
FROM ruby:3.1

# Set the working directory inside the container
WORKDIR /app

# Copy the current directory contents to the container's working directory
COPY . .

# Install any necessary gems from Gemfile
RUN bundle install

# Define the command to run your script
CMD ["ruby", "stock.rb"]
