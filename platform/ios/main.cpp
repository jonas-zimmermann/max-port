// Phase 1: SDL's native UIKit bootstrap. No original game assets are bundled.
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

int main(int, char**) {
    SDL_SetHint(SDL_HINT_ORIENTATIONS, "LandscapeLeft LandscapeRight");
    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("iOS bootstrap: %s", SDL_GetError());
        return 1;
    }
    SDL_Window* window = nullptr;
    SDL_Renderer* renderer = nullptr;
    if (!SDL_CreateWindowAndRenderer("M.A.X. Port", 960, 540, SDL_WINDOW_FULLSCREEN, &window, &renderer)) {
        SDL_Log("iOS window: %s", SDL_GetError());
        SDL_Quit();
        return 1;
    }
    SDL_SetRenderLogicalPresentation(renderer, 960, 540, SDL_LOGICAL_PRESENTATION_LETTERBOX);
    bool running = true;
    while (running) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT) running = false;
        }
        SDL_SetRenderDrawColor(renderer, 16, 24, 32, 255);
        SDL_RenderClear(renderer);
        SDL_SetRenderDrawColor(renderer, 240, 240, 240, 255);
        SDL_RenderDebugText(renderer, 40, 80, "M.A.X. Port - native iOS foundation");
        SDL_RenderDebugText(renderer, 40, 112, "Original game data is not included.");
        SDL_RenderDebugText(renderer, 40, 144, "Data import and game startup are planned for the next phase.");
        SDL_RenderPresent(renderer);
        SDL_Delay(16);
    }
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
