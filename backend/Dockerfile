# Stage 1: Build the Go binary
FROM golang:1.19-alpine AS builder

WORKDIR /app

# Copy go module files first (for layer caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the binary
RUN go build -o main .

# Stage 2: Run in a minimal image (keeps image size small)
FROM alpine:3.17

WORKDIR /app

# Copy only the compiled binary from builder stage
COPY --from=builder /app/main .

# Expose backend port
EXPOSE 8080

CMD ["./main"]
