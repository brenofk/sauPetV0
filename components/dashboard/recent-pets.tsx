"use client"

import { useEffect, useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Heart, Plus, ArrowRight } from "lucide-react"
import { useRouter } from "next/navigation"

interface Pet {
  id: string
  name: string
  species: "cachorro" | "gato"
  breed?: string
  created_at: string
}

export function RecentPets() {
  const [pets, setPets] = useState<Pet[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const router = useRouter()
  const supabase = createClient()

  useEffect(() => {
    const fetchRecentPets = async () => {
      try {
        const { data, error } = await supabase
          .from("pets")
          .select("id, name, species, breed, created_at")
          .order("created_at", { ascending: false })
          .limit(3)

        if (error) throw error
        setPets(data || [])
      } catch (error) {
        console.error("Erro ao carregar pets recentes:", error)
      } finally {
        setIsLoading(false)
      }
    }

    fetchRecentPets()
  }, [])

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Heart className="w-5 h-5 text-primary" />
            <span>Pets Recentes</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="animate-pulse flex items-center space-x-3">
                <div className="w-10 h-10 bg-muted rounded-xl"></div>
                <div className="flex-1">
                  <div className="w-24 h-4 bg-muted rounded mb-1"></div>
                  <div className="w-16 h-3 bg-muted rounded"></div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
        <CardTitle className="flex items-center space-x-2">
          <Heart className="w-5 h-5 text-primary" />
          <span>Pets Recentes</span>
        </CardTitle>
        <Button variant="ghost" size="sm" onClick={() => router.push("/pets")} className="text-primary">
          Ver todos
          <ArrowRight className="w-4 h-4 ml-1" />
        </Button>
      </CardHeader>
      <CardContent>
        {pets.length === 0 ? (
          <div className="text-center py-6">
            <Heart className="w-12 h-12 text-muted-foreground mx-auto mb-3" />
            <p className="text-muted-foreground mb-3">Nenhum pet cadastrado ainda</p>
            <Button size="sm" onClick={() => router.push("/pets")} className="rounded-xl">
              <Plus className="w-4 h-4 mr-2" />
              Adicionar Pet
            </Button>
          </div>
        ) : (
          <div className="space-y-3">
            {pets.map((pet) => (
              <div
                key={pet.id}
                className="flex items-center space-x-3 p-3 border border-border rounded-xl hover:bg-muted/50 transition-colors cursor-pointer"
                onClick={() => router.push("/pets")}
              >
                <div className="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
                  <Heart className="w-5 h-5 text-primary" />
                </div>
                <div className="flex-1">
                  <h3 className="font-medium text-foreground">{pet.name}</h3>
                  <div className="flex items-center space-x-2">
                    <Badge variant="secondary" className="text-xs">
                      {pet.species === "cachorro" ? "🐕 Cachorro" : "🐱 Gato"}
                    </Badge>
                    {pet.breed && <span className="text-xs text-muted-foreground">{pet.breed}</span>}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
